module Support
  class CaseContactDetailsForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :first_name, Types::Params::String | Types::Nil, optional: true
    option :last_name, Types::Params::String | Types::Nil, optional: true
    option :email, Types::Params::String, optional: true, default: proc { "" }
    option :phone, Types::Params::String | Types::Nil, optional: true
    option :extension_number, Types::Params::String | Types::Nil, optional: true

    def self.from_case(kase)
      new(first_name: kase.first_name, last_name: kase.last_name, email: kase.email, phone: kase.phone_number, extension_number: kase.extension_number)
    end

    def update_contact_details(kase, agent_id)
      CaseManagement::UpdateCaseContactDetails.new.call(
        support_case_id: kase.id,
        agent_id:,
        first_name:,
        last_name:,
        phone:,
        email:,
        extension_number:,
      )
    end
  end
end
