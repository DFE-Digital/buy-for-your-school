#
# School Business Professionals seeking assistance can complete this form to open
# a case with the Supported Buying team
#
class SupportForm < Form
  # @see [SupportRequest] attributes
  option :phone_number, optional: true # 1
  option :school, optional: true       # 2
  option :journey_id, optional: true   # 3 (option for 'none')
  option :category_id, optional: true  # 4 (skipped if 3)
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
