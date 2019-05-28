require "../../observer"
require "../../cancellable"
require "../../subscription"

class OnErrorMaybeObserver(T) < MaybeObserver(T)
  include Cancellable

  @onSuccess : Proc(T, Nil)
  @onError : Proc(Exception, Nil)
  @withSubscription : Bool
  @state : Subscription

  def initialize(@onSuccess : Proc(T, Nil), @onError : Proc(Exception, Nil))
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
        @onSuccess.call(x)
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
      begin
        @onError.call(e)
      ensure
        @state.cancel()
      end
    else
      raise e
    end
  end
end
