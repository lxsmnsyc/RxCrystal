require "../../RxCrystal"

class LambdaCompletableObserver(T)
  include CompletableObserver(T)
  include Cancellable

  @onComplete : (Proc(Void))?
  @onSuccess : (Proc(T, Nil))?
  @onError : (Proc(Exception, Nil))?

  @withSubscription : Bool
  @state : Subscription
  @alive : Bool

  def initialize(@onSuccess : Proc(T, Nil), @onComplete : Proc(Void), @onError : Proc(Exception, Nil))
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
        @onComplete.call()
      ensure
        self.cancel()
      end
    end
  end

  def onError(e : Exception)
    if (@withSubscription && @alive)
      begin
        @onError.call(e)
      ensure
        self.cancel()
      end
    else
      raise e
    end
  end
end