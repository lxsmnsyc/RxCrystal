require "./cancellable"

module Subscription
  include Cancellable
end

class BasicSubscription
  include Subscription

  @alive : Bool

  def initialize
    @alive = true
  end

  def cancel
    @alive = false
  end

  def alive
    @alive
  end
end