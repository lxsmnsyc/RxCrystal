require "../../observer"
require "../../emitter"
require "../../observable"

module ObservableCreate(T)
  def subscribeActual(observer : ObservableObserver(T))
    emitter = ObservableEmitter(T).new observer

    observer.onSubscribeemitter

    begin
      @subscriber.call emitter
    rescue ex
      emitter.onError ex
    end 
  end

  def create(subscriber : ObservableEmitter(T) -> Nil) : Observable::Observable(T)
    
  end
end