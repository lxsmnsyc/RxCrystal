require "./transformer"
require "./operator"
require "./observer"

abstract class Completable
  def |(transformer : CompletableTransformer) : Completable
    transformer.apply(self)
  end

  abstract def subscribeActual(observer : CompletableObserver)
end

