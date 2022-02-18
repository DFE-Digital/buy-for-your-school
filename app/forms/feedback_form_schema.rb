# Validate user feedback form
#
class FeedbackFormSchema < Schema
  config.messages.top_namespace = :feedback

  params do
    optional(:satisfaction).value(:string)
    optional(:feedback_text).value(:string)
    optional(:full_name).value(:string)
    optional(:email).value(:string)
  end

  rule(:satisfaction) do
    key.failure(:missing) if value.blank?
  end

  rule(:full_name) do
    key.failure(:missing) if key? && value.blank?
  end

  rule(:email) do
    key.failure(:missing) if key? && value.blank?
  end

  rule(:email) do
    if key? && (value.blank? || !URI::MailTo::EMAIL_REGEXP.match?(value))
      key.failure(:format?)
    end
  end
end
