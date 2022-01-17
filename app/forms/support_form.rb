# @abstract Form Object for multi-step questionnaires
#
# @author Peter Hamilton
#
class SupportForm < Form
  # @!attribute [r] phone_number
  # @see SupportRequest SupportRequest attributes
  # @return [String]
  option :phone_number, optional: true # 1
  # @!attribute [r] school_urn
  # @see SupportRequest SupportRequest attributes
  # @return [String]
  option :school_urn, optional: true # 2 (skipped if only one supported school)
  # @!attribute [r] journey_id
  # @see SupportRequest SupportRequest attributes
  # @return [String]
  option :journey_id, optional: true # 3 (option for 'none')
  # @!attribute [r] category_id
  # @see SupportRequest SupportRequest attributes
  # @return [String]
  option :category_id, optional: true # 4 (skipped if 3)
  # @!attribute [r] message_body
  # @see SupportRequest SupportRequest attributes
  # @return [String]
  option :message_body, optional: true # 5 (last)

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
