module CaseHistory
  class HandleCaseStateChanges
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

    def case_held_by_system(payload)
      Support::Interaction.state_change.create!(
        body: "Case placed on hold due to #{payload[:reason]}",
        case_id: payload[:support_case_id],
      )
    end

    def case_organisation_changed(payload)
      record_state_change("Case organisation changed", payload)
    end

    def case_contact_details_changed(payload)
      record_state_change("Case contact details changed", payload)
    end

  private

    def record_state_change(reason, payload)
      Support::Interaction.state_change.create!(
        body: reason,
        case_id: payload[:case_id],
        agent_id: payload[:agent_id],
        additional_data: additional_data_from(payload),
      )
    end

    def additional_data_from(payload)
      payload.except(:case_id, :agent_id).merge({ format_version: "2" })
    end
  end
end
