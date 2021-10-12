require "types"
require "dry-initializer"

# Form object to handle creation of SupportRequests
#
# @author Peter Hamilton
#
class SupportForm < MultiStepForm
  # @see [SupportRequest] attributes
  option :phone_number, optional: true # 1
  option :journey_id, optional: true   # 2 (option for 'none')
  option :category_id, optional: true  # 3 (skipped if 2)
  option :message_body, optional: true # 4 (last)

  # used to determine how to navigate
  option :total_steps, optional: true, default: proc { 4 }
  option :user_journeys, optional: true, default: proc { [] }

  # Calculate how many steps to progress forwards based on current step.
  # Users may skip over certain steps based on their setup.
  #
  # @return [Integer] number of steps to navigate backwards
  def steps_to_move_forwards
    case step
    when 1 then skip_a_step_if_no_user_journeys
    when 2 then skip_a_step_if_chosen_journey
    else
      1
    end
  end

  # Calculate how many steps to progress backwards based on current step.
  # Users may skip over certain steps based on their setup.
  #
  # @return [Integer] number of steps to navigate backwards
  def steps_to_move_backwards
    case step
    when 3 then skip_a_step_if_no_user_journeys
    when 4 then skip_a_step_if_chosen_journey
    else
      1
    end
  end

  # @see SupportRequestsController#create
  #
  # @return [Boolean] journey UUID is present
  def has_journey?
    journey_id.present? && journey_id != "none"
  end

  # @see SupportRequestsController#update
  #
  # @return [Boolean] category UUID is present
  def has_category?
    category_id.present?
  end

  # @return [nil]
  def forget_category!
    instance_variable_set :@category_id, nil
  end

  # @return [nil]
  def forget_journey!
    instance_variable_set :@journey_id, nil
  end

private

  def skip_a_step_if_no_user_journeys
    user_journeys.none? ? 2 : 1
  end

  def skip_a_step_if_chosen_journey
    has_journey? ? 2 : 1
  end
end
