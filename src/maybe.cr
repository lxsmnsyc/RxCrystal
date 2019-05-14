require "./transformer"
require "./operator"
require "./observer"

abstract class Maybe(T)
  def |(transformer : MaybeTransformer(U, D)) : Maybe(D)
    transformer.apply(self)
  end

  abstract def subscribeActual(observer : MaybeObserver(T))
end

