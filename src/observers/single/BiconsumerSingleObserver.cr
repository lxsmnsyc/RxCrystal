require "../../SingleObserver"
require "../../Subscription"
require "../../subscriptions/BasicSubscription"

class BiconsumerSingleObserver(T)
  include SingleObserver(T)
  include Subscription

  @upstream : Proc(T, Nil)
  @withSubscription : Bool
  @state : Subscription
  @alive : Bool

  def initialize(@upstream : Proc(T, Exception, Nil))
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

  def onSuccess(x : T)
    if (@withSubscription && @alive)
      begin
        @upstream.call(x, Nil)
      ensure
        self.cancel
      end
    end
  end

  def onError(e : Exception)
    if (@withSubscription && @alive)
      begin
        @upstream.call(Nil, e)
      ensure
        self.cancel
      end
    else
      raise e
    end
  end
end
