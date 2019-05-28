require "../../observer"
require "../../cancellable"
require "../../subscription"

class OnErrorMaybeObserver(T) < MaybeObserver(T)
  include Cancellable

  @upstream : Proc(Exception, Nil)
  @withSubscription : Bool
  @state : Subscription

  def initialize(@upstream : Proc(Exception, Nil))
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
      @state.cancel()
    end
  end

  def onComplete
    if (@withSubscription && @alive)
      @state.cancel()
    end
  end

  def onError(e : Exception)
    if (@withSubscription && @alive)
      begin
        @upstream.call(e)
      ensure
        @state.cancel()
      end
    else
      raise e
    end
  end
end
