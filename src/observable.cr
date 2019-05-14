require "./transformer"
require "./operator"
require "./observer"

abstract class Observable(T)
  def |(transformer : ObservableTransformer(U, D)) : Observable(D)
    transformer.apply(self)
  end

  abstract def subscribeActual(observer : ObservableObserver(T))
end

