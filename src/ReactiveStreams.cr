module ReactiveStreams
  # A `Subscription` represents a one-to-one lifecycle
  # of a `Subscriber` subscribing to a `Publisher`.
  #
  # It can only be used once by a single `Subscriber`.
  #
  # It is used to both signal desire for data and cancel
  # demand (and allow resource cleanup).
  module Subscription
    # No events will be sent by a `Publisher` until demand
    # is signaled via this method.
    #
    # It can be called however often and whenever needed—but
    # if the outstanding cumulative demand ever becomes
    # `Int64.MAX` or more, it may be treated by the `Publisher`
    # as "effectively unbounded".
    #
    # Whatever has been requested can be sent by the `Publisher`
    # so only signal demand for what can be safely handled.
    #
    # A `Publisher` can send less than is requested if the
    # stream ends but then must emit either `Subscriber#onError`
    # or `Subscriber#onComplete`.
    abstract def request(amount : Int64)

    # Request the `Publisher` to stop sending data and clean up
    # resources.
    #
    # Data may still be sent to meet previously signalled demand
    # after calling cancel.
    abstract def cancel
  end

  
  # Will receive call to `#onSubscribe` once after
  # passing an instance of `Subscriber` to `Publisher#subscribe`.
  #
  # No further notifications will be received until
  # `Subscription#request` is called.
  #
  # After signaling demand:
  #
  # - One or more invocations of `#onNext` up to the
  # maximum number defined by `Subscription#request`.
  # - Single invocation of `#onError` or `Subscriber#onComplete`
  # which signals a terminal state after which no
  # further events will be sent.
  #
  # Demand can be signaled via `Subscription#request`
  # whenever the `Subscriber` instance is capable of
  # handling more.
  module Subscriber(T)
    # Invoked after calling `Publisher#subscribe`.
    #
    # No data will start flowing until `Subscription#request` is invoked.
    #
    # It is the responsibility of this `Subscriber` instance
    # to call `Subscription#request` whenever more data is wanted.
    #
    # The `Publisher` will send notifications only in response
    # to `Subscription#request`.
    abstract def onSubscribe(subscription : Subscription)

    # Data notification sent by the `Publisher` in
    # response to requests to `Subscription#request`.
    abstract def onNext(x : T)

    # Failed terminal state.
    #
    # No further events will be sent even if `Subscription#request`
    # is invoked again.
    abstract def onError(e : Exception)

    # Successful terminal state.
    #
    # No further events will be sent even if `Subscription#request`
    # is invoked again.
    abstract def onComplete
  end

  # A `Publisher` is a provider of a potentially unbounded
  # number of sequenced elements, publishing them according
  # to the demand received from its `Subscriber`(s).
  #
  # A `Publisher` can serve multiple `Subscriber`s subscribed
  # `#subscribe` dynamically at various points in time.
  module Publisher(T)
    # Request `Publisher` to start streaming data.
    #
    # This is a "factory method" and can be called multiple times,
    # each time starting a new `Subscription`.
    #
    # Each `Subscription` will work for only a single `Subscriber`.
    #
    # A `Subscriber` should only subscribe once to a single `Publisher`.
    #
    # If the `Publisher` rejects the subscription attempt or otherwise fails it will
    # signal the error via `Subscriber#onError`.
    abstract def subscribe(subscriber : Subscriber(T))
  end

  # A Processor represents a processing stage—which is both a `Subscriber`
  # and a `Publisher` and obeys the contracts of both.
  module Processor(T, R)
    include Publisher(R)
    include Subscriber(T)
  end
end
