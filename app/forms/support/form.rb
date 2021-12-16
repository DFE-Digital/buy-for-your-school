module Support
  #
  # Base form object
  #
  class Form
    extend Dry::Initializer

    # @!attribute [r] messages
    #   @return [Hash] field validation error messages
    option :messages, Types::Hash, default: proc { {} }

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

    # Populate form object with validation messages and form fields from given validation
    #
    # @param [Support::Schema] validation
    #
    # @return [Support::Form]
    def self.from_validation(validation)
      new(messages: validation.errors(full: true).to_h, **validation.to_h)
    end

    # @see https://govuk-form-builder.netlify.app/introduction/error-handling/
    #
    # @return [Support::Form::ErrorSummary]
    def errors
      ErrorSummary.new(messages)
    end

    # @return [Hash] form params
    def to_h
      self.class.dry_initializer.public_attributes(self).except(:messages)
    end
  end
end
