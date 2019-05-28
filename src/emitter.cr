require "./cancellable"

module SingleEmitter(T)
  abstract def setCancellable(cancellable : Cancellable)
  abstract def onSuccess(x : T)
  abstract def onError(e : Exception)
  abstract def isCancelled
end

module CompletableEmitter
  abstract def setCancellable(cancellable : Cancellable)
  abstract def onComplete
  abstract def onError(e : Exception)
  abstract def isCancelled
end

module MaybeEmitter(T)
  abstract def setCancellable(cancellable : Cancellable)
  abstract def onComplete
  abstract def onSuccess(x : T)
  abstract def onError(e : Exception)
  abstract def isCancelled
end

module ObservableEmitter(T)
  abstract def setCancellable(cancellable : Cancellable)
  abstract def onComplete
  abstract def onError(e : Exception)
  abstract def onNext(x : T)
  abstract def isCancelled
end