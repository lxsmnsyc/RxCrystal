# Reactive Extensions - represents a state of cancellation
module Cancellable
  # Abstract class for the `Cancellable` classes
  abstract class Cancellable
    # :nodoc:
    def initialize
      @listeners = [] of Proc(Nil)
    end

    # Returns true if the instance is cancelled.
    abstract def cancelled

    # Cancels the instance.
    abstract def cancel

    # Registers a listener function to a target event dispatcher.
    # These functions are called when the `Cancellable` instance
    # is cancelled
    def addListener(listener : Proc(Nil))
      @listeners << listener
    end

    # Removes a listener function from a target event dispatcher.
    def removeListener(listener : Proc(Nil))
      @listeners.delete listener
    end

    # :nodoc:
    protected def dispatch
      @listeners.each do |listener|
        listener.call
      end
    end
  end

  private class UncancelledCancellable < Cancellable
    def cancelled
      false
    end

    def cancel
      false
    end
  end

  private class CancelledCancellable < Cancellable
    def cancelled
      true
    end

    def cancel
      false
    end
  end

  # A `Cancellable` instance that can never be cancelled.
  UNCANCELLED = UncancelledCancellable.new

  # A `Cancellable` instance that is always cancelled
  CANCELLED = CancelledCancellable.new

  # A `Cancellable` class that represents a boolean state
  class BooleanCancellable < Cancellable
    @state : Cancellable
    # Creates a BooleanCancellable
    def initialize
      super
      @state = UNCANCELLED
    end

    # Returns true if the instance is cancelled.
    def cancelled
      @state.cancelled
    end

    # Cancels the instance
    def cancel
      if !cancelled
        @state = CANCELLED
        dispatch
        return true
      end
      return false
    end
  end

  # A `Cancellable` class that allows composition of `Cancellable` instances.
  class CompositeCancellable < Cancellable
    @state : Cancellable
    # Creates a CompositeCancellable
    def initialize
      super
      @state = UNCANCELLED
      @buffer = [] of Cancellable
    end

    # Returns true if the instance is cancelled.
    def cancelled
      @state.cancelled
    end

    # Cancels the instances contained.
    def cancel
      if !cancelled
        temp = @buffer
        @buffer = [] of Cancellable

        temp.each do |instance|
          instance.cancel
        end

        @state = CANCELLED
        dispatch
        return true
      end
      return false
    end

    # Adds the given `Cancellable` into the composite.
    def add(c : Cancellable)
      if !(c == self)
        if cancelled
          c.cancel
        else
          @buffer << c
          return true
        end
      end
      return false
    end

    # Removes the given `Cancellable` from the composite.
    def remove(c : Cancellable)
      if !(c == self)
        @buffer.delete c
        return true
      end
      return false
    end
  end

  # A `Cancellable` class that allows linking on `Cancellable` instances.
  #
  # A LinkedCancellable will be disposed when the linked Cancellable
  # instance is disposed and vice-versa
  class LinkedCancellable < Cancellable
    @origin : Cancellable
    @linked : Cancellable
    @listener : Proc(Nil)
    # Creates a LinkedCancellable
    def initialize
      super
      ref = BooleanCancellable.new
      @origin = ref
      @linked = ref
      @listener = ->{ nil }
    end

    # Returns true if the instance is cancelled.
    def cancelled
      @origin.cancelled
    end

    # Cancels this instance and the linked instance.
    def cancel
      if !cancelled
        if !(@origin == @linked)
          @linked.cancel
          unlink
          @linked = @origin
        end
        @origin.cancel
        dispatch
        return true
      end
      return false
    end

    # Links to a Cancellable instance.
    def link(c : Cancellable)
      if !(c == self)
        if cancelled
          c.cancel
        elsif c.cancelled
          cancel
        else
          unlink
          @linked = c

          @listener = ->{ cancel; nil }
          c.addListener @listener
          return true
        end
      end
      return false
    end

    # Unlinks this cancellable
    def unlink
      if (!cancelled && !(@origin == @linked))
        @linked.removeListener @listener
        @listener = ->{ nil }

        @linked = @origin
        return true
      end
      return false
    end
  end
end