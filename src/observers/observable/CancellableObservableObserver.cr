require "../../ObservableObserver"
require "../../Subscription"
require "../../subscriptions/BasicSubscription"

class CancellableObservableObserver(T)
  include ObservableObserver(T)
  include Subscription

  @withSubscription : Bool
  @state : Subscription
  @alive : Bool

  def initialize(@upstream : ObservableObserver(T))
    @state = BasicSubscription.new
    @withSubscription = false
    @alive = true
  end

  def cancel
    if (@alive)
      @alive = false
      @state.cancel
    end
  end

  def onSubscribe(x : Subscription)
    if (@withSubscription)
      x.cancel
    else
      @withSubscription = true
      @state = x
    end
  end

  def onNext(x : T)
    if (@withSubscription && @alive)
      begin
        @upstream.onNext(x)
      end
    end
  end

  def onComplete
    if (@withSubscription && @alive)
      begin
        @upstream.onComplete
      ensure
        self.cancel
      end
    end
  end

  def onError(e : Exception)
    if (@withSubscription && @alive)
      begin
        @upstream.onError(e)
      ensure
        self.cancel
      end
    else
      raise e
    end
  end
end
