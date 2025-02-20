#
# Validate "support request" form details from a "school business professional"
#
# If a specification is not selected, the user must choose a category
#
# @author Peter Hamilton
#
class SupportFormSchema < RequestFormSchema
  config.messages.top_namespace = :support_request

  params do
    optional(:phone_number).value(:string)  # step 1
    optional(:school_urn).value(:string)    # step 2
    optional(:journey_id).value(:string)    # step 3
    optional(:category_id).value(:string)   # step 4
    optional(:message_body).value(:string)  # step 5
  end

  # temporarily disabled until the service supports calls
  # rule(:phone_number).validate(max_size?: 13, format?: /^$|^(0|\+?44)[12378]\d{8,9}$/)

  rule(:school_urn) do
    key.failure(:missing) if key? && value.blank?
  end

  rule(:journey_id, :category_id) do
    key(:category_id).failure(:no_spec) if key?(:category_id) && values[:category_id].blank? && ["none", ""].include?(values[:journey_id])
  end

  rule(:message_body) do
    key.failure(:missing) if key? && value.blank?
  end
end
