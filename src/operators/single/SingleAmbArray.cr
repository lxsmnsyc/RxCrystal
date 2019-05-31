require "../../Single"
require "../../SingleSource"
require "../../SingleObserver"
require "../../Subscription"
require "../../subscriptions/CompositeSubscription"

private class SingleAmbObserver(T)
  include SingleObserver(T)

  def initialize(@observer : SingleObserver(T), @subscription : CompositeSubscription, @winner : Atomic(Int8))
  end

  def onSubscribe(sub : Subscription)
    @subscription.add(sub)
  end

  def onSuccess(x : T)
    if (@winner.compare_and_set(0, 1))
      begin
        @observer.onSuccess(x)
      ensure
        @subscription.cancel
      end
    end
  end

  def onError(e : Exception)
    if (@winner.compare_and_set(0, 1))
      begin
        @observer.onError(e)
      ensure
        @subscription.cancel
      end
    else
      raise(e)
    end
  end
end

class SingleAmbArray(T) < Single(T)
  def initialize(@sources : Array(SingleSource(T)))
  end

  def subscribeActual(observer : SingleObserver(T))
    winner = Atomic(Int8).new(0)
    subscription = CompositeSubscription.new

    observer.onSubscribe(subscription)

    @sources.each do |x|
      if (subscription.alive)
        x.subscribe(SingleAmbObserver(T).new(observer, subscription, winner))
      end
    end
  end
end