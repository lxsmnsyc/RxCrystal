require "./cancellable"
require "./observer"

include Cancellable
include Observer

module Emitter
  private module SuccessHandler
    # Emits a success value.
    def onSuccess(x : T)
      if !cancelled
        begin
          if x == nil
            @observer.onError Exception.new "onSuccess called with a nil value"
          else
            @observer.onSuccess x
          end
        ensure
          cancel
        end
      end
    end
  end
  private module CompletionHandler
    # Emits a completion.
    def onComplete
      if !cancelled
        begin
          @observer.onComplete
        ensure
          cancel
        end
      end
    end
  end
  private module ErrorHandler
    # Emits an error value
    def onError(x : Exception)
      report = x
      if x == nil
        report = Exception.new "onError called with a nil value"
      end
      if !cancelled
        begin
          @observer.onError report
        ensure
          cancel
        end
      else
        raise report
      end
    end
  end

  # super class for Emitter classes
  class Emitter < Cancellable::Cancellable
    @linked : Cancellable::Cancellable
    def initialize
      super
      @linked = BooleanCancellable.new
    end
    
    # Returns true if the emitter is cancelled.
    def cancelled
      @linked.cancelled
    end

    # Returns true if the emitter is cancelled successfully.
    def cancel
      @linked.cancel
    end

    # Set the given `Cancellable` as the `Emitter`'s cancellable state.
    def setCancellable(c : Cancellable::Cancellable)
      if cancelled
        c.cancel
      elsif c.cancelled
        cancel
        return true 
      else
        @linked.cancel
        @linked = c
        return true
      end
      return false
    end
  end

  # Abstraction over a `MaybeObserver` that allows associating
  # a resource with it.
  # 
  # Calling onSuccess(Object) multiple times has no effect.
  # Calling onComplete() multiple times has no effect.
  # Calling onError(Error) multiple times has no effect.
  class MaybeEmitter(T) < Emitter
    def initialize(@observer : MaybeObserver(T))
      super()
    end

    include SuccessHandler
    include CompletionHandler
    include ErrorHandler
  end

  # Abstraction over a SingleObserver that allows associating
  # a resource with it.
  #
  # Calling onSuccess(Object) multiple times has no effect.
  # Calling onError(Error) multiple times or after onSuccess
  # has no effect.
  class SingleEmitter(T) < Emitter
    def initialize(@observer : SingleObserver(T))
      super()
    end

    include SuccessHandler
    include ErrorHandler
  end

  # Abstraction over a CompletableObserver that allows associating
  # a resource with it.
  #
  # Calling onComplete() multiple times has no effect.
  # Calling onError(Error) multiple times or after onComplete
  # has no effect.
  class CompletableEmitter < Emitter
    def initialize(@observer : CompletableObserver)
      super()
    end

    include CompletionHandler
    include ErrorHandler
  end

  class ObservableEmitter(T) < Emitter
    def initialize(@observer : ObservableObserver(T))
      super()
    end

    def onNext(x : T)
      if !cancelled
        @observer.onNext x
      end
    end

    include CompletionHandler
    include ErrorHandler
  end
end