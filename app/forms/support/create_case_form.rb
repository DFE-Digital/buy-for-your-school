# frozen_string_literal: true

module Support
  class CreateCaseForm
    extend Dry::Initializer
    include Concerns::ValidatableForm
    include Concerns::RequestDetailsFormFields

    option :organisation_id, optional: true
    option :organisation_type, optional: true
    option :organisation_name, optional: true
    option :organisation_urn, optional: true
    option :first_name, optional: true
    option :last_name, optional: true
    option :email, optional: true
    option :phone_number, optional: true
    option :extension_number, optional: true
    option :source, optional: true
    option :procurement_amount, ->(value) { value&.gsub(/[£,]/, "") }, optional: true

    # @return [Hash] form parms
    def to_h
      self.class.dry_initializer.attributes(self)
          .except(:messages, :request_type)
          .compact
    end

    def create_case
      CreateCase.new(to_h).call
    end
  end
end
