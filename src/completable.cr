require "./transformer"
require "./operator"
require "./observer"

abstract class CompletableSource(T)
  abstract def subscribe(observer : CompletableObserver(T))
end

abstract class Completable
  include CompletableSource(T)

  def |(transformer : CompletableTransformer) : Completable
    transformer.apply(self)
  end

  abstract def subscribeActual(observer : CompletableObserver)
end

