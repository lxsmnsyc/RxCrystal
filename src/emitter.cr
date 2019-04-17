require "./cancellable"

module Emitter
  private module CancellableAssociation

  end
  private module SuccessHandler
    # Emits a success value.
    def onSuccess(x : T)
      if !cancelled
        begin
          if x == nil
            @error.call Exception.new "onSuccess called with a nil value"
          else
            @success.call x
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
          @complete.call
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
          @error.call report
        ensure
          cancel
        end
      else
        raise report
      end
    end
  end
  class Emitter < Cancellable::Cancellable
    @linked : Cancellable::Cancellable
    def initialize
      super
      @linked = Cancellable::BooleanCancellable.new
    end
    
    # Returns true if the emitter is cancelled.
    def cancelled
      @linked.cancelled
    end

    # Returns true if the emitter is cancelled successfully.
    def cancel
      @linked.cancel
    end

    # Set the given Cancellable as the Emitter's cancellable state.
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
  # Abstraction over a MaybeObserver that allows associating
  # a resource with it.
  # 
  # Calling onSuccess(Object) multiple times has no effect.
  # Calling onComplete() multiple times has no effect.
  # Calling onError(Error) multiple times has no effect.
  class MaybeEmitter(T) < Emitter
    def initialize(@success : Proc(T, Nil), @complete : Proc(Nil), @error : Proc(Exception, Nil))
      super()
    end

    include SuccessHandler
    include CompletionHandler
    include ErrorHandler
  end

  class SingleEmitter(T) < Emitter
    def initialize(@success : Proc(T, Nil), @error : Proc(Exception, Nil))
      super()
    end

    include SuccessHandler
    include ErrorHandler
  end

  class CompletableEmitter < Emitter
    def initialize(@complete : Proc(Nil), @error : Proc(Exception, Nil))
      super()
    end

    include CompletionHandler
    include ErrorHandler
  end

  class ObservableEmitter(T) < Emitter
    def initialize(@next : Proc(T, Nil), @error : Proc(Exception, Nil), @complete : Proc(Nil))
      super()
    end

    def onNext(x : T)
      if !cancelled
        @next.call x
      end
    end

    include CompletionHandler
    include ErrorHandler
  end
end