require "./cancellable"
require "./emitter"
require "./observer"

require "./operators/observable/*"

include ObserverModule
include CancellableModule
include EmitterModule

module ObservableModule
  extend self
  abstract class Observable(T)
    abstract def subscribeActual(observer : ObservableObserver(T))

    def subscribeWith(observer : ObservableObserver(T))
      subscribeActual observer
    end
  end
end