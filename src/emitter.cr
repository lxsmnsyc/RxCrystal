require "./cancellable"

module SingleEmitter(T)
  abstract def addCleanup(cleanup : Proc(Void))
  abstract def onSuccess(x : T)
  abstract def onError(e : Exception)
  abstract def isCancelled : Bool
end

module CompletableEmitter
  abstract def addCleanup(cleanup : Proc(Void))
  abstract def onComplete
  abstract def onError(e : Exception)
  abstract def isCancelled : Bool
end

module MaybeEmitter(T)
  abstract def addCleanup(cleanup : Proc(Void))
  abstract def onComplete
  abstract def onSuccess(x : T)
  abstract def onError(e : Exception)
  abstract def isCancelled : Bool
end

module ObservableEmitter(T)
  abstract def addCleanup(cleanup : Proc(Void))
  abstract def onComplete
  abstract def onError(e : Exception)
  abstract def onNext(x : T)
  abstract def isCancelled : Bool
end