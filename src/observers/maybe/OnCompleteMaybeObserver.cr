require "../../MaybeObserver"
require "../../Subscription"
require "../../subscriptions/BasicSubscription"

class OnCompleteMaybeObserver(T)
  include MaybeObserver(T)
  include Subscription

  @upstream : (Proc(Void))?
  @withSubscription : Bool
  @state : Subscription
  @alive : Bool

  def initialize(@upstream : Proc(Void))
    @state = BasicSubscription.new
    @withSubscription = false
    @alive = true
  end

  def cancel
    if (@alive)
      @alive = false
      @state.cancel()
    end
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
      self.cancel()
    end
  end

  def onComplete
    if (@withSubscription && @alive)
      begin
        @upstream.call()
      ensure
        self.cancel()
      end
    end
  end

  def onError(e : Exception)
    if (@withSubscription && @alive)
      self.cancel()
    else
      raise e
    end
  end
end
