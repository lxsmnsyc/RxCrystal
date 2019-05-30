require "../../Completable"
require "../../CompletableObserver"
require "../../SingleObserver"
require "../../Subscription"

private class SingleIgnoreElementObserver(T)
  include SingleObserver(T)
  include Subscription

  @withSubscription : Bool
  @alive : Bool
  @ref : Subscription

  def initialize(@upstream : CompletableObserver)
    @withSubscription = false
    @alive = true
    @ref = BasicSubscription.new
    @upstream.onSubscribe(self)
  end

  def onSubscribe(s : Subscription)
    if (@withSubscription)
      s.cancel
    else
      @withSubscription = true
      @ref = s
    end
  end

  def cancel
    if (@alive)
      if (@withSubscription)
        @ref.cancel
      end
      @alive = false
    end
  end

  def onSuccess(value : T)
    if (@withSubscription && @alive)
      begin
        @upstream.onComplete
      rescue ex
        @upstream.onError(ex)
      ensure
        cancel()
      end
    end
  end

  def onError(e : Exception)
    if (@withSubscription && @alive)
      begin
        @upstream.onError(e)
      ensure
        cancel()
      end
    end
  end
end

class SingleIgnoreElement(T) < Completable
  def initialize(@source : Single(T))
  end

  def subscribeActual(observer : CompletableObserver)
    @source.subscribeActual(SingleIgnoreElementObserver(T).new(observer))
  end
end