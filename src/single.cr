require "./operator"
require "./observer"

module SingleSource(T)
  abstract def subscribe(observer : SingleObserver(T))
end

abstract class Single(T)
  include SingleSource(T)

  abstract def subscribeActual(observer : SingleObserver(T))
end

