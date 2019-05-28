require "../../observer"
require "../../cancellable"
require "../../subscription"

class OnCompleteMaybeObserver(T)
  include MaybeObserver(T)
  include Cancellable

  @upstream : Proc(Void)
  @withSubscription : Bool
  @state : Subscription

  def initialize(@upstream : Proc(Void))
    @state = BasicSubscription.new
    @withSubscription = false
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
      @state.cancel()
    end
  end

  def onComplete
    if (@withSubscription && @alive)
      begin
        @upstream.call()
      ensure
        @state.cancel()
      end
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
