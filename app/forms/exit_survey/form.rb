#
# Base form object
#
class ExitSurvey::Form
  extend Dry::Initializer
  # extend Dry::Initializer[undefined: false]

  # @!attribute [r] messages
  #   @return [Hash] field validation error messages
  option :messages, Types::Hash, default: proc { {} }

  # @return [Hash] overridden form params as request attributes
  def to_h
    self.class.dry_initializer.attributes(self)
  end

  # @return [Hash] form params as request attributes
  def data
    to_h.except(:messages)
  end

  # @see https://govuk-form-builder.netlify.app/introduction/error-handling/
  #
  # @return [Form::ErrorSummary]
  def errors
    ErrorSummary.new(messages)
  end

  #
  # Message object for form error handling
  #
  class ErrorSummary
    extend Dry::Initializer

    # @!attribute [r] messages
    #
    # @example
    #   { phone_number: ["size cannot be less than 10"] }
    #
    # @return [Hash]
    param :messages, Types::Hash, default: proc { {} }

    delegate :any?, to: :messages
  end
end
