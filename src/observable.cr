require "./transformer"
require "./operator"
require "./observer"

module ObservableSource(T)
  abstract def subscribe(observer : ObservableObserver(T))
end

abstract class Observable(T)
  include ObservableSource(T)

  def |(transformer : ObservableTransformer(U, D)) : Observable(D)
    transformer.apply(self)
  end

  abstract def subscribeActual(observer : ObservableObserver(T))
end

