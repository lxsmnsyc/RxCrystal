require "../../maybe"
require "../../emitter"
require "../../subscription"
require "../../observer"

private class MaybeCreateEmitter(T)
  include Subscription
  include MaybeEmitter(T)

  def initialize(upstream : MaybeObserver(T))
    @cleanup = [] of Proc(Void)
    @alive = true
  end

  private def callCleanup
    @cleanup.each do |x|
      x.call()
    end
    @alive = false
  end

  def addCleanup(cleanup : Proc(Void))
    @cleanup << cleanup
  end

  def onSuccess(x : T)
  end

  def onError(e : Exception)
    if (@alive)
      begin
        @upstream.onError(e)
      ensure
        callCleanup()
      end
    end
  end

  def onComplete
    if (@alive)
      begin
        @upstream.onComplete()
      ensure
        callCleanup()
      end
    end
  end

  def isCancelled
    return !@alive
  end
end

class MaybeCreate(T) < Maybe(T)
  def initialize(@onSubscribe : Proc(MaybeEmitter(T), Nil))
  end

  def subscribeActual(observer : MaybeObserver(T))
    emitter = MaybeCreateEmitter.new(observer)

    observer.onSubscribe(PureSubscription.new(emitter))

    begin
      @onSubscribe(emitter)
    rescue ex
      emitter.onError(ex)
    end
  end
end