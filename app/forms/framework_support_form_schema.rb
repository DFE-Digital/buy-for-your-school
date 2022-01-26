# :nocov:
#
# Validate "find-a-framework support requests"
#
class FrameworkSupportFormSchema < Schema
  config.messages.top_namespace = :framework_request

  params do
    optional(:dsi).value(:bool)               # step 1

    optional(:first_name).value(:string)      # step 2
    optional(:last_name).value(:string)       # step 2

    optional(:email).value(:string)           # step 3

    optional(:school_urn).value(:string)      # step 4
    optional(:message_body).value(:string)    # step 5
  end

  rule(:dsi) do
    key.failure(:missing) unless key?
  end

  rule(:first_name) do
    key.failure(:missing) if key? && value.blank?
  end

  rule(:last_name) do
    key.failure(:missing) if key? && value.blank?
  end

  rule(:email) do
    if key? && (value.blank? || !URI::MailTo::EMAIL_REGEXP.match?(value))
      key.failure(:missing)
    end
  end

  # rule(:email) do
  #   unless !key? || URI::MailTo::EMAIL_REGEXP.match?(value)
  #     key.failure(:invalid)
  #   end
  # end

  rule(:school_urn) do
    key.failure(:missing) if key? && value.blank?
  end

  rule(:message_body) do
    key.failure(:missing) if key? && value.blank?
  end
end
# :nocov:
