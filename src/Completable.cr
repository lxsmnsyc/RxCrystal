require "./operator"
require "./observer"

module CompletableSource
  abstract def subscribe(observer : CompletableObserver)
end

abstract class Completable
  include CompletableSource

  abstract def subscribeActual(observer : CompletableObserver)
end

