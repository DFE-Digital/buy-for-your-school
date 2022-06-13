module Support
  class CaseRequestDetailsForm
    extend Dry::Initializer
    include Concerns::ValidatableForm
    include Concerns::RequestDetailsFormFields
  end
end
