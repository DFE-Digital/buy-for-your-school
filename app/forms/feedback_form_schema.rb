# Validate user feedback form
#
class FeedbackFormSchema < Schema
  params do
    required(:satisfaction).value(:symbol)
    optional(:feedback_text).value(:string)
  end
end
