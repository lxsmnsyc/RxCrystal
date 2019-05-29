require "./cancellable"

module Subscription
  include Cancellable
end

class PureSubscription
  include Subscription

  def initialize(@base : Subscription)
  end

  def cancel
    @base.cancel()
  end
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