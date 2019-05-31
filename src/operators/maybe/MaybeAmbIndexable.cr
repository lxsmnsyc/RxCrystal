require "../../Maybe"
require "../../MaybeSource"
require "../../MaybeObserver"
require "../../Subscription"
require "../../subscriptions/CompositeSubscription"

private class MaybeAmbObserver(T)
  include MaybeObserver(T)

  def initialize(@observer : MaybeObserver(T), @subscription : CompositeSubscription, @winner : Atomic(Int8))
  end

  def onSubscribe(sub : Subscription)
    @subscription.add(sub)
  end

  def onComplete
    if (@winner.compare_and_set(0, 1))
      begin
        @observer.onComplete
      ensure
        @subscription.cancel
      end
    end
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

class MaybeAmbIndexable(T) < Maybe(T)
  def initialize(@sources : Indexable(MaybeSource(T)))
  end

  def subscribeActual(observer : MaybeObserver(T))
    winner = Atomic(Int8).new(0)
    subscription = CompositeSubscription.new

    observer.onSubscribe(subscription)

    @sources.each.each do |x|
      if (subscription.alive)
        x.subscribe(MaybeAmbObserver(T).new(observer, subscription, winner))
      end
    end
  end
end