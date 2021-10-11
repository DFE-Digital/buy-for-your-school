# @abstract Logic to enable a user to navigate through steps of a SupportForm
# forwards and backwards and potentially skip steps in either direction.
#
# @author Ryan Kendall
#
class SupportRequests::Navigation
  attr_reader :user_journeys, :support_form

  def initialize(user_journeys:, support_form:)
    @user_journeys = user_journeys
    @support_form = support_form
  end

  def navigate
    steps_to_move.times { move_in_direction }
  end

private

  def steps_to_move
    if (step.in?([1, 3]) && user_journeys.none?) || (step.in?([2, 4]) && has_journey?)
      2
    else
      1
    end
  end

  def move_in_direction
    direction = { backwards: :back!, forwards: :advance! }[support_form.direction.to_sym]
    support_form.send(direction)
  end

  def step
    support_form.step
  end

  def has_journey?
    support_form.has_journey?
  end
end
