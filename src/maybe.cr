require "./transformer"
require "./operator"
require "./observer"
require "./subscription"
require "./observers/maybe/**"

module MaybeSource(T)
  abstract def subscribe(observer : MaybeObserver(T))
end

abstract class Maybe(T)
  include MaybeSource(T)

  def |(transformer : MaybeTransformer(U, D)) : Maybe(D)
    transformer.apply(self)
  end

  abstract def subscribeActual(observer : MaybeObserver(T))

  def subscribeWith(observer : MaybeObserver(T)) : MaybeObserver(T)
    self.subscribeActual(observer)
    return observer
  end

  def subscribe(observer : MaybeObserver(T)) : Subscription
    observer = CancellableMaybeObserver.new(observer)
    self.subscribeActual(observer)
    return observer
  end

  def subscribe(onSuccess : Proc(T, Nil)) : Subscription
    observer = OnSuccessMaybeObserver.new(onSuccess)
    self.subscribeActual(observer)
    return observer
  end

  def subscribe(onSuccess : Proc(T, Nil), onError : Proc(Exception, Nil)) : Subscription
    observer = onErrorMaybeObserver.new(onSuccess, onError)
    self.subscribeActual(observer)
    return observer
  end

  def subscribe(onSuccess : Proc(T, Nil), onComplete : Proc(Void), onError : Proc(Exception, Nil)) : Subscription
    observer = LambdaMaybeObserver.new(onSuccess, onComplete, onError)
    self.subscribeActual(observer)
    return observer
  end
end

