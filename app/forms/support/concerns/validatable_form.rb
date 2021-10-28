module Support
  module Concerns
    class ErrorSummary
      extend Dry::Initializer

      # @example
      #
      #   { phone_number: ["size cannot be less than 10"] }
      #
      param :messages, Types::Hash, default: proc { {} }

      delegate :any?, to: :messages
    end

    module ValidatableForm
      extend ActiveSupport::Concern

      included do
        # field validation error messages
        option :messages, Types::Hash, default: proc { {} }
      end

      # @see https://govuk-form-builder.netlify.app/introduction/error-handling/
      #
      # @return [ErrorSummary]
      def errors
        ErrorSummary.new(messages)
      end

      class_methods do
        # Populate form object with validation messages and form fields from given validation
        #
        # @param [Concerns::TranslatableFormSchema] validation
        #
        # @return [Concerns::ValidatableForm]
        def from_validation(validation)
          new(messages: validation.errors(full: true).to_h, **validation.to_h)
        end
      end
    end
  end
end
