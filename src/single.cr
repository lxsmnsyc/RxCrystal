require "./transformer"
require "./operator"
require "./observer"

module SingleSource(T)
  abstract def subscribe(observer : SingleObserver(T))
end

abstract class Single(T)
  include SingleSource(T)

  def |(transformer : SingleTransformer(U, D)) : Single(D)
    transformer.apply(self)
  end

  abstract def subscribeActual(observer : SingleObserver(T))
end

