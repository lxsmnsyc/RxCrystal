
# Abstract class for the `Cancellable` classes
module Cancellable
  # :nodoc:
  def initialize
    @listeners = [] of Proc(Nil)
  end

  # Returns true if the instance is cancelled.
  abstract def cancelled : Bool

  # Cancels the instance.
  abstract def cancel : Bool

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