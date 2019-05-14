require "./cancellable"

module Observer
  abstract def onSubscribe(c : Cancellable)
end

module GenericObserver
  include Observer
  abstract def onError(x : Exception)
end

module SingleObserver(T)
  include GenericObserver
  abstract def onSuccess(x : T)
end

module CompletableObserver
  include GenericObserver
  abstract def onComplete
end

module MaybeObserver(T)
  include SingleObserver(T)
  include CompletableObserver
end

module ObservableObserver(T)
  include CompletableObserver
  abstract def onNext(x : T)
end