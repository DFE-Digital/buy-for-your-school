# Validate user feedback form
#
class FeedbackFormSchema < Schema
  config.messages.top_namespace = :feedback

  params do
    optional(:satisfaction).value(:symbol)
    optional(:feedback_text).value(:string)
  end

  rule(:satisfaction) do
    key.failure(:missing) if value.blank?
  end
end
