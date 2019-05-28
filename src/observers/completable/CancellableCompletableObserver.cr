require "../../RxCrystal"

class CancellableCompletableObserver(T)
  include CompletableObserver(T)
  include Cancellable

  @upstream : CompletableObserver(T)
  @withSubscription : Bool
  @state : Subscription
  @alive : Bool

  def initialize(@upstream : CompletableObserver(T))
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

  def onComplete
    if (@withSubscription && @alive)
      begin
        @upstream.onComplete()
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
