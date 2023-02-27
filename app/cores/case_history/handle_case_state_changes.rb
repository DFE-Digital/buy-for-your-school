module CaseHistory
  class HandleCaseStateChanges
    def agent_assigned_to_case(payload)
      Support::Interaction.case_assigned.create!(
        body: "Case assigned",
        case_id: payload[:support_case_id],
        agent_id: payload[:assigned_by_agent_id],
        additional_data: {
          format_version: "2",
          assigned_to_agent_id: payload[:assigned_to_agent_id],
        },
      )
    end

    def case_opened(payload)
      Support::Interaction.case_opened.create!(
        body: "Case openend",
        case_id: payload[:support_case_id],
        agent_id: payload[:agent_id],
        additional_data: {
          format_version: "2",
          triggered_by: payload[:reason],
        },
      )
    end

    def case_reopened_due_to_received_email(payload)
      Support::Interaction.state_change.create!(
        body: "Case reopened due to receiving new email",
        case_id: payload[:support_case_id],
        additional_data: {
          email_id: payload[:support_email_id],
        },
      )
    end
  end
end
