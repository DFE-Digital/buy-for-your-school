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
class SupportForm < Form
  # @!attribute [r] phone_number
  # @see SupportRequest SupportRequest attributes
  # @return [String]
  option :phone_number, optional: true

  # @!attribute [r] school_urn
  # @see SupportRequest SupportRequest attributes
  # @return [String]
  option :school_urn, optional: true

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
