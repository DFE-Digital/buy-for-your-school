#
# Validate "find-a-framework support requests"
#
class FafFormSchema < Schema
  params do
    optional(:dsi).value(:bool)
    optional(:message_body).value(:string)  # step 5
    optional(:school_urn).value(:string)
  end

  rule(:dsi) do
    key.failure(:missing) unless key?
  end

  rule(:message_body) do
    key.failure(:missing) if key? && value.blank?
  end

  rule(:school_urn) do
    key.failure(:missing) if key? && value.blank?
  end
end
