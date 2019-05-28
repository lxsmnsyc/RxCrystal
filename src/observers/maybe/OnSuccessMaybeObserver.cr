require "../../observer"
require "../../cancellable"
require "../../subscription"

class OnSuccessMaybeObserver(T)
  include MaybeObserver(T)
  include Cancellable

  @upstream : Proc(T, Nil)
  @withSubscription : Bool
  @state : Subscription
  @alive : Bool

  def initialize(@upstream : Proc(T, Nil))
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
      begin
        @upstream.call(x)
      ensure
        self.cancel()
      end
    end
  end

  def onComplete
    if (@withSubscription && @alive)
      self.cancel()
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
