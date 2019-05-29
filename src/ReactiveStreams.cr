
module ReactiveStreams
  module Subscription
    abstract def request(amount : Int)
    abstract def cancel
  end
  module Subscriber(T)
    abstract def onSubscribe(subscription : Subscription)
    abstract def onNext(x : T)
    abstract def onError(e : Exception)
    abstract def onComplete()
  end
  module Publisher(T)
    abstract def subscribe(subscriber : Subscriber(T))
  end
  module Processor(T)
    include Publisher(T)
    include Subscriber(T)
  end
end