require "./transformer"
require "./operator"
require "./observer"

abstract class Single(T)
  def |(transformer : SingleTransformer(U, D)) : Single(D)
    transformer.apply(self)
  end

  abstract def subscribeActual(observer : SingleObserver(T))
end

