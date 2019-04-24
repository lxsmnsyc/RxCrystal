require "./cancellable"

module ObserverModule
  abstract class GenericObserver
    abstract def onSubscribe(x : Cancellable::Cancellable)
    abstract def onError(x : Exception)
  end
  abstract class ObservableObserver(T) < GenericObserver
    abstract def onNext(x : T)
    abstract def onComplete
  end
  abstract class MaybeObserver(T) < GenericObserver
    abstract def onSuccess(x : T)
    abstract def onComplete
  end
  abstract class SingleObserver(T) < GenericObserver
    abstract def onSuccess(x : T)
  end
  abstract class CompletableObserver < GenericObserver
    abstract def onComplete
  end
end