module CaseManagement
  class UpdateCaseAdditionalContacts
    include Wisper::Publisher

    def call(support_case_id:, first_name:, last_name:, phone:, email:, extension_number:, role:)
      support_case = Support::Case.find(support_case_id)
      support_case.update!(
        first_name:,
        last_name:,
        phone_number: phone,
        email:,
        extension_number:,
        role:,
      )

      broadcast(:case_additional_contacts_changed, {
        case_id: support_case_id,
        first_name:,
        last_name:,
        phone_number: phone,
        email:,
        extension_number:,
        role:,
      })
    end
  end
end
