require "./observer"
require "./emitter"
require "./subscription"
require "./observers/maybe/*"

module MaybeSource(T)
  abstract def subscribe(observer : MaybeObserver(T))
end

abstract class Maybe(T)
  include MaybeSource(T)


  def subscribeWith(observer : MaybeObserver(T)) : MaybeObserver(T)
    subscribeActual(observer)
    return observer
  end

  def subscribe(observer : MaybeObserver(T))
    subscribeActual(observer)
  end

  def subscribe(onSuccess : Proc(T, Nil)) : Subscription
    observer = OnSuccessMaybeObserver.new(onSuccess)
    subscribeActual(observer)
    return observer
  end

  def subscribe(onSuccess : Proc(T, Nil), onError : Proc(Exception, Nil)) : Subscription
    observer = onErrorMaybeObserver.new(onSuccess, onError)
    subscribeActual(observer)
    return observer
  end

  def subscribe(onSuccess : Proc(T, Nil), onComplete : Proc(Void), onError : Proc(Exception, Nil)) : Subscription
    observer = LambdaMaybeObserver.new(onSuccess, onComplete, onError)
    subscribeActual(observer)
    return observer
  end

  abstract def subscribeActual(observer : MaybeObserver(T))
end

