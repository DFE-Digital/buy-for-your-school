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

class BaseForm
  extend Dry::Initializer

  # @!attribute [r] messages
  # @return [Hash] field validation error messages
  option :messages, Types::Hash, default: proc { {} }

  # @see https://govuk-form-builder.netlify.app/introduction/error-handling/
  #
  # @return [ErrorSummary]
  def errors
    ErrorSummary.new(messages)
  end

  # Populate form object with validation messages and form fields from given validation
  #
  # @param [Concerns::TranslatableFormSchema] validation
  #
  # @return [Concerns::ValidatableForm]
  def self.from_validation(validation)
    new(messages: validation.errors(full: true).to_h, **validation.to_h)
  end
end
