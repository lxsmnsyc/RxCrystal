require "../../RxCrystal"

class OnErrorMaybeObserver(T)
  include MaybeObserver(T)
  include Cancellable

  @onSuccess : (Proc(T, Nil))?
  @onError : (Proc(Exception, Nil))?
  @withSubscription : Bool
  @state : Subscription
  @alive : Bool

  def initialize(@onSuccess : Proc(T, Nil), @onError : Proc(Exception, Nil))
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
        @onSuccess.call(x)
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
