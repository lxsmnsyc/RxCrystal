#
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
require "../../MaybeCore"
require "../../MaybeSource"
require "../../MaybeObserver"
require "../../Subscription"

# :nodoc:
private class MaybeMapObserver(T, R)
  include MaybeObserver(T)
  include Subscription

  @withSubscription : Bool
  @alive : Bool
  @ref : Subscription

  def initialize(@upstream : MaybeObserver(R), @mapper : Proc(T, R))
    @withSubscription = false
    @alive = true
    @ref = BasicSubscription.new
    @upstream.onSubscribe(self)
  end

  def onSubscribe(s : Subscription)
    if (@withSubscription)
      s.cancel
    else
      @withSubscription = true
      @ref = s
    end
  end

  def cancel
    if (@alive)
      if (@withSubscription)
        @ref.cancel
      end
      @alive = false
    end
  end

  def onSuccess(value : T)
    if (@withSubscription && @alive)
      begin
        @upstream.onSuccess(@mapper.call(value))
      rescue ex
        @upstream.onError(ex)
      ensure
        cancel()
      end
    end
  end

  def onError(e : Exception)
    if (@withSubscription && @alive)
      begin
        @upstream.onError(e)
      ensure
        cancel()
      end
    else
      raise(e)
    end
  end
end

# :nodoc:
class MaybeMap(T, R) < Maybe(R)
  def initialize(@source : Maybe(T), @mapper : Proc(T, R))
  end

  def subscribeActual(observer : MaybeObserver(R))
    @source.subscribeActual(MaybeMapObserver(T, R).new(observer, @mapper))
  end
end
