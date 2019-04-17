require "./cancellable"
require "./emitter"
require "./observer"

require "./operators/observable/create"

include Observer
include Cancellable
include Emitter

module Observable
  private class LambdaObserver(T) < ObservableObserver(T)
    @state : LinkedCancellable

    @next : T -> Nil
    @error : Exception -> Nil
    @complete : Proc(Nil)

    def initialize(@next : T -> Nil, @error : Exception -> Nil, @complete : Proc(Nil))
      @state = LinkedCancellable.new
    end

    def onSubscribe(x : Cancellable::Cancellable)
      @state.link x
    end

    def onComplete
      @complete.call
    end

    def onError(x : Exception)
      @error.call x
    end

    def onNext(x : T)
      @next.call x
    end

    def state
      @state
    end
  end

  abstract class Observable(T)
    def self.create(subscriber : ObservableEmitter(T) -> Nil)
      ObservableCreate::ObservableCreate.new subscriber
    end

    def |(operator : Observable(T) -> Observable(T))
      operator.call self
    end

    abstract def subscribeActual(observer : ObservableObserver(T))

    def subscribeWith(observer : ObservableObserver(T))
      subscribeActual observer
    end

    def subscribe(onNext : T -> Nil, onError : Exception -> Nil, onComplete : Proc(Nil))
      observer = LambdaObserver(T).new(onNext, onError, onComplete)
      state = observer.state
      subscribeWith observer
      return state
    end
  end
end
Observable::Observable(String).create(->(e: ObservableEmitter(String)){
  e.onNext("Hello")
  e.onNext("World")
  e.onComplete
})

.subscribe(
  ->(x : String){ puts x },
  ->(x : Exception) { puts x },
  ->{ puts "Completed" }
)