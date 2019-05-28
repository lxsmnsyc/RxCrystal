require "../../observer"
require "../../cancellable"
require "../../subscription"

class OnErrorSingleObserver(T)
  include SingleObserver(T)
  include Cancellable

  @upstream : Proc(Exception, Nil)
  @withSubscription : Bool
  @state : Subscription
  @alive : Bool

  def initialize(@upstream : Proc(Exception, Nil))
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

  def onError(e : Exception)
    if (@withSubscription && @alive)
      begin
        @upstream.call(e)
      ensure
        self.cancel()
      end
    else
      raise e
    end
  end
end
