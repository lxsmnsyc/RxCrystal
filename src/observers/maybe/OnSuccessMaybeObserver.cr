require "../../observer"
require "../../cancellable"
require "../../subscription"

class OnSuccessMaybeObserver(T) < MaybeObserver(T)
  include Cancellable

  @upstream : Proc(T, Nil)
  @withSubscription : Bool
  @state : Subscription

  def initialize(@upstream : Proc(T, Nil))
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
    if (@withSubscription && @alive)
      begin
        @upstream.call(x)
      ensure
        @state.cancel()
      end
    end
  end

  def onComplete
    if (@withSubscription && @alive)
      @state.cancel()
    end
  end

  def onError(e : Exception)
    if (@withSubscription && @alive)
      @state.cancel()
    else
      raise e
    end
  end
end
