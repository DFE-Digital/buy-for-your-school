module Support
  class CaseRequestDetailsForm
    extend Dry::Initializer
    include Concerns::ValidatableForm
    include Concerns::RequestDetailsFormFields
    attr_accessor :agent_id

    def update!(support_case)
      super

      Support::CaseCategorisationChangeLogger.new(support_case:, agent_id:).log!
    end
  end
end
