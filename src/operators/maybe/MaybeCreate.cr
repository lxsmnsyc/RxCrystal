require "../../MaybeCore"
require "../../MaybeEmitter"
require "../../MaybeObserver"
require "../../Subscription"

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

  def cancel
    if (@alive)
      self.callCleanup()
    end
  end

  def onSuccess(x : T)
    if (@alive)
      begin
        @upstream.onSuccess(x)
      ensure
        self.callCleanup()
      end
    end
  end

  def onError(e : Exception)
    if (@alive)
      begin
        @upstream.onError(e)
      ensure
        self.callCleanup()
      end
    end
  end

  def onComplete
    if (@alive)
      begin
        @upstream.onComplete()
      ensure
        self.callCleanup()
      end
    end
  end

  def isCancelled
    return !@alive
  end
end

private class MaybeCreate(T) < Maybe(T)
  def initialize(@onSubscribe : Proc(MaybeEmitter(T), Nil))
  end

  def subscribeActual(observer : MaybeObserver(T))
    emitter = MaybeCreateEmitter.new(observer)

    observer.onSubscribe(emitter)

    begin
      @onSubscribe.call(emitter)
    rescue ex
      emitter.onError(ex)
    end
  end
end


def Maybe.create(onSubscribe : Proc(MaybeEmitter(T), Nil))
  return MaybeCreate(T).new(onSubscribe)
end