# @abstract Form Object for multi-step questionnaires
#
# @author Peter Hamilton
#
#   1: phone_number   (temporarily disbaled until the service supports calls)
#   2: school_urn     (skipped if only one supported school)
#   3: journey_id     (option for 'none')
#   4: category_id    (skipped if journey)
#   5: message_body   (last and compulsory)
#
class SupportForm < RequestForm
  # @!attribute [r] user
  #   @return [UserPresenter]
  option :user, ::Types.Constructor(UserPresenter)

  # @!attribute [r] step
  # @return [Integer]
  option :step, Types::Params::Integer, default: proc {
    if user.supported_schools.one?
      user.active_journeys.any? ? 3 : 4
    else
      2
    end
  }

  # @!attribute [r] phone_number
  # @see SupportRequest SupportRequest attributes
  # @return [String]
  option :phone_number, optional: true # awaiting service readiness review

  # @!attribute [r] school_urn
  # @see SupportRequest SupportRequest attributes
  # @return [String]
  # option :school_urn, optional: true
  option :school_urn, default: proc { user.school_urn }

  # @!attribute [r] journey_id
  # @see SupportRequest SupportRequest attributes
  # @return [String]
  option :journey_id, optional: true

  # @!attribute [r] category_id
  # @see SupportRequest SupportRequest attributes
  # @return [String]
  option :category_id, optional: true

  # @!attribute [r] message_body
  # @see SupportRequest SupportRequest attributes
  # @return [String]
  option :message_body, optional: true

  # @return [Boolean]
  def jump_to_category?
    position?(3) && !has_journey?
  end

  # @return [nil] request can be about either a category or a specific specification
  def toggle_subject
    if position?(3) && has_journey?
      forget_category!
    elsif position?(4) && has_category?
      forget_journey!
    end
  end

  # Conditional jumps to different steps or incremental move forward
  #
  # @return [Integer]
  def forward
    if position?(2) && user.active_journeys.none?
      go_to!(4)
    elsif position?(3) && has_journey?
      go_to!(5)
    else
      advance!
    end
  end

  # Conditional jumps to different steps or incremental move backward
  #
  # @return [Integer]
  def backward
    if position?(4) && user.active_journeys.none?
      go_to!(2)
    elsif position?(5) && has_journey?
      go_to!(3)
    else
      back!
    end
  end

  # @return [Hash] toggle form data to step backward
  def go_back
    to_h.merge(back: true)
  end

private

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
    !category_id.nil?
  end

  # @return [nil]
  def forget_category!
    instance_variable_set :@category_id, nil
  end

  # @return [nil]
  def forget_journey!
    instance_variable_set :@journey_id, nil
  end
end
