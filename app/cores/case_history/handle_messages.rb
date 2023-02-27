module CaseHistory
  class HandleMessages
    def received_email_attached_to_case(payload)
      Support::Interaction.email_from_school.find_or_create_by(
        body: "Received email from school",
        case_id: payload[:support_case_id],
        additional_data: { email_id: payload[:support_email_id] },
      )
    end

    def sent_email_attached_to_case(payload)
      Support::Interaction.email_to_school.find_or_create_by(
        body: "Sent email to school",
        case_id: payload[:support_case_id],
        additional_data: { email_id: payload[:support_email_id] },
      )
    end
  end
end
