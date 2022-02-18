# Collect user feedback
#
class FeedbackForm < Form
  # @!attribute [r] service
  # @return [Symbol]
  option :service, Types::Params::Symbol, default: proc { :create_a_specification }

  # @!attribute [r] satisfaction
  # @return [Symbol]
  option :satisfaction, Types::Params::Symbol, optional: true

  # @!attribute [r] feedback_text
  # @return [String]
  option :feedback_text, Types::String, optional: true

  # @!attribute [r] full_name
  # @return [String]
  option :full_name, Types::String, optional: true

  # @!attribute [r] email
  # @return [String]
  option :email, Types::String, optional: true
end
