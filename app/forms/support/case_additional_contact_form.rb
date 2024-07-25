module Support
  class CaseAdditionalContactForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :first_name, Types::Params::String | Types::Nil, optional: true
    option :last_name, Types::Params::String | Types::Nil, optional: true
    option :email, Types::Params::String, optional: true, default: proc { "" }
    option :phone_number, Types::Params::String | Types::Nil, optional: true
    option :extension_number, Types::Params::String | Types::Nil, optional: true
    option :role, Types::Params::String | Types::Array, optional: true

    def self.from_case(additional_contact)
      new(first_name: additional_contact.first_name, last_name: additional_contact.last_name, email: additional_contact.email, phone: additional_contact.phone_number, extension_number: additional_contact.extension_number, role: additional_contact.role)
    end

    def update_contact_details(kase)
      CaseManagement::UpdateCaseAdditionalContacts.new.call(
        support_case_id: kase.id,
        first_name:,
        last_name:,
        phone:,
        email:,
        extension_number:,
        role:,
      )
    end
  end
end
