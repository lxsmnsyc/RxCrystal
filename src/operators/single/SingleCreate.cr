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
require "../../SingleCore"
require "../../SingleEmitter"
require "../../SingleObserver"
require "../../Subscription"

# :nodoc:
private class SingleCreateEmitter(T)
  include Subscription
  include SingleEmitter(T)

  def initialize(upstream : SingleObserver(T))
    @cleanup = [] of Proc(Void)
    @alive = true
  end

  private def callCleanup
    @cleanup.each do |x|
      x.call
    end
    @alive = false
  end

  def addCleanup(cleanup : Proc(Void))
    @cleanup << cleanup
  end

  def cancel
    if (@alive)
      self.callCleanup
    end
  end

  def onSuccess(x : T)
    if (@alive)
      begin
        @upstream.onSuccess(x)
      ensure
        self.callCleanup
      end
    end
  end

  def onError(e : Exception)
    if (@alive)
      begin
        @upstream.onError(e)
      ensure
        self.callCleanup
      end
    end
  end

  def isCancelled
    return !@alive
  end
end

# :nodoc:
class SingleCreate(T) < Single(T)
  def initialize(@onSubscribe : Proc(SingleEmitter(T), Nil))
  end

  def subscribeActual(observer : SingleObserver(T))
    emitter = SingleCreateEmitter(T).new(observer)

    observer.onSubscribe(emitter)

    begin
      @onSubscribe.call(emitter)
    rescue ex
      emitter.onError(ex)
    end
  end
end
