require "../../observer"
require "../../cancellable"
require "../../subscription"

class CancellableMaybeObserver(T) < MaybeObserver(T)
  include Cancellable

  @upstream : MaybeObserver(T)
  @withSubscription : Bool
  @state : Subscription

  def initialize(@upstream : MaybeObserver(T))
    @state = BasicSubscription.new
  end

  def cancel
    @state.cancel()
  end

  def onSubscribe(x : Subscription)
    if (@withSubscription)
      x.cancel()
    else
      @withSubscription = true
      @state = x
    end
  end

  def onSuccess(x : T)
    if (@withSubscription && @state)
      begin
        @upstream.onSuccess(x)
      ensure
        @state.cancel()
      end
    end
  end

  def onComplete
    if (@withSubscription && @state)
      begin
        @upstream.onComplete()
      ensure
        @state.cancel()
      end
    end
  end

  def onError(e : Exception)
    if (@withSubscription && @state)
      begin
        @upstream.onError(e)
      ensure
        @state.cancel()
      end
    else
      raise e
    end
  end
end
