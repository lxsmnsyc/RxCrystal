
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