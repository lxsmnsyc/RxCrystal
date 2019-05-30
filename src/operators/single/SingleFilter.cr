require "../../Maybe"
require "../../Single"
require "../../MaybeObserver"
require "../../SingleObserver"
require "../../Subscription"

private class SingleFilterObserver(T)
  include SingleObserver(T)
  include Subscription

  @withSubscription : Bool
  @alive : Bool
  @ref : Subscription

  def initialize(@upstream : MaybeObserver(T), @filter : Proc(T, Bool))
    @withSubscription = false
    @alive = true
    @ref = BasicSubscription.new
    @upstream.onSubscribe(self)
  end

  def onSubscribe(s : Subscription)
    if (@withSubscription)
      s.cancel
    else
      @withSubscription = true
      @ref = s
    end
  end

  def cancel
    if (@alive)
      if (@withSubscription)
        @ref.cancel
      end
      @alive = false
    end
  end

  def onSuccess(value : T)
    if (@withSubscription && @alive)
      begin
        if (@filter.call(value))
          @upstream.onSuccess(value)
        else
          @upstream.onComplete
        end
      rescue ex
        @upstream.onError(ex)
      ensure
        cancel()
      end
    end
  end

  def onError(e : Exception)
    if (@withSubscription && @alive)
      begin
        @upstream.onError(e)
      ensure
        cancel()
      end
    end
  end
end

class SingleFilter(T) < Maybe(T)
  def initialize(@source : Single(T), @filter : Proc(T, Bool))
  end

  def subscribeActual(observer : MaybeObserver(T))
    @source.subscribeActual(SingleFilterObserver(T).new(observer, @filter))
  end
end