# frozen_string_literal: true

module Support
  class CreateCaseForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :organisation_id, optional: true
    option :organisation_type, optional: true
    option :organisation_name, optional: true
    option :organisation_urn, optional: true
    option :first_name, optional: true
    option :last_name, optional: true
    option :email, optional: true
    option :phone_number, optional: true
    option :extension_number, optional: true
    option :category_id, optional: true
    option :query_id, optional: true
    option :request_type, Types::ConfirmationField, optional: true
    option :other_category, optional: true
    option :other_query, optional: true
    option :source, optional: true
    option :request_text, optional: true

    # @return [Hash] form parms
    def to_h
      self.class.dry_initializer.attributes(self)
          .except(:messages, :request_type)
          .compact
    end

    # @return [Boolean]
    def request_type?
      instance_variable_get :@request_type
    end
  end
end
