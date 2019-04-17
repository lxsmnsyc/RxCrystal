require "../../observer"
require "../../emitter"
require "../../observable"

module ObservableMap
  class ObservableMap(T) < Observable::Observable(T)
    def initialize(@mapper : T -> T)
      super
    end

    def subscribeActual(observer : ObservableObserver(T))
      
    end
  end
end