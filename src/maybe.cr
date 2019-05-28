require "./transformer"
require "./operator"
require "./observer"

abstract class MaybeSource(T)
  abstract def subscribe(observer : MaybeObserver(T))
end

abstract class Maybe(T)
  include MaybeSource(T)

  def |(transformer : MaybeTransformer(U, D)) : Maybe(D)
    transformer.apply(self)
  end

  abstract def subscribeActual(observer : MaybeObserver(T))
end

