module CaseManagement
  class UpdateCaseContactDetails
    include Wisper::Publisher

    def call(support_case_id:, agent_id:, first_name:, last_name:, phone:, email:, extension_number:)
      support_case = Support::Case.find(support_case_id)
      support_case.update!(
        first_name:,
        last_name:,
        phone_number: phone,
        email:,
        extension_number:,
      )

      broadcast(:case_contact_details_changed, {
        case_id: support_case_id,
        agent_id:,
        first_name:,
        last_name:,
        phone_number: phone,
        email:,
        extension_number:,
      })
    end
  end
end
