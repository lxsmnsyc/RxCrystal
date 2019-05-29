#
# @license
# MIT License
#
# Copyright (c) 2019 Alexis Munsayac
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#
# author Alexis Munsayac <alexis.munsayac@gmail.com>
# copyright Alexis Munsayac 2019
#

require "./MaybeObserver"
require "./MaybeSource"
require "./Subscription"


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

