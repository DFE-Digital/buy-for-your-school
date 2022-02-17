# Collect user feedback
#
class FeedbackForm < Form
  # @!attribute [r] satisfaction
  # @return [Symbol]
  option :satisfaction

  # @!attribute [r] feedback_text
  # @return [String]
  option :feedback_text
end
