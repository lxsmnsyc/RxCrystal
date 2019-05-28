require "../../observer"
require "../../cancellable"
require "../../subscription"

class CancellableSingleObserver(T)
  include SingleObserver(T)
  include Cancellable

  @upstream : SingleObserver(T)
  @withSubscription : Bool
  @state : Subscription
  @alive : Bool

  def initialize(@upstream : SingleObserver(T))
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
        @upstream.onSuccess(x)
      ensure
        self.cancel()
      end
    end
  end

  def onError(e : Exception)
    if (@withSubscription && @alive)
      begin
        @upstream.onError(e)
      ensure
        self.cancel()
      end
    else
      raise e
    end
  end
end
