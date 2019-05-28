require "./operator"
require "./observer"

module ObservableSource(T)
  abstract def subscribe(observer : ObservableObserver(T))
end

abstract class Observable(T)
  include ObservableSource(T)

  abstract def subscribeActual(observer : ObservableObserver(T))
end

