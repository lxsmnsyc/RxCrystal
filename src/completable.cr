require "./transformer"
require "./operator"
require "./observer"

module CompletableSource
  abstract def subscribe(observer : CompletableObserver)
end

abstract class Completable
  include CompletableSource

  def |(transformer : CompletableTransformer) : Completable
    transformer.apply(self)
  end

  abstract def subscribeActual(observer : CompletableObserver)
end

