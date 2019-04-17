require "../../observer"
require "../../emitter"
require "../../observable"

module ObservableCreate
  class ObservableCreate(T) < Observable::Observable(T)
    def initialize(@subscriber : ObservableEmitter(T) -> Nil)
      super
    end

    def subscribeActual(observer : ObservableObserver(T))
      emitter = ObservableEmitter(T).new observer

      observer.onSubscribe(emitter)

      begin
        @subscriber.call emitter
      rescue ex
        emitter.onError(ex)
      end 
    end
  end
end