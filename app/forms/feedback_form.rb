# Collect user feedback
#
class FeedbackForm < Form
  # @!attribute [r] service
  # @return [Symbol]
  option :service, Types::Symbol, default: proc { :create_a_specification }

  # @!attribute [r] satisfaction
  # @return [Symbol]
  option :satisfaction, Types::Symbol, optional: true

  # @!attribute [r] feedback_text
  # @return [String]
  option :feedback_text, Types::String, optional: true
end
