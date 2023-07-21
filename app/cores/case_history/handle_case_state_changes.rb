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

    def case_source_changed(payload)
      record_state_change("Source changed", payload)
    end

    def case_value_changed(payload)
      record_state_change("Case value changed", payload)
    end

    def case_categorisation_changed(payload)
      if payload[:category_id].present? && payload[:query_id].present?
        record_change_of_category_and_query(payload)
      elsif payload[:category_id].present?
        record_change_of_category(payload)
      elsif payload[:query_id].present?
        record_change_of_query(payload)
      end
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

    def record_change_of_category(payload)
      from, to = payload[:category_id]
      record_categorisation_change(from:, to:, type: :category, case_id: payload[:case_id], agent_id: payload[:agent_id])
    end

    def record_change_of_query(payload)
      from, to = payload[:query_id]
      record_categorisation_change(from:, to:, type: :query, case_id: payload[:case_id], agent_id: payload[:agent_id])
    end

    def record_change_of_category_and_query(payload)
      category_from, category_to = payload[:category_id]
      query_from, query_to       = payload[:query_id]

      if category_from.present? && category_to.nil? && query_to.present?
        record_categorisation_change(from: category_from, to: query_to, type: :category_to_query, case_id: payload[:case_id], agent_id: payload[:agent_id])
      elsif query_from.present? && query_to.nil? && category_to.present?
        record_categorisation_change(from: query_from, to: category_to, type: :query_to_category, case_id: payload[:case_id], agent_id: payload[:agent_id])
      end
    end

    def record_categorisation_change(from:, to:, type:, case_id:, agent_id:)
      Support::Interaction.case_categorisation_changed.create!(
        case_id:,
        additional_data: { from:, to:, type: },
        agent_id:,
        body: "Categorisation change",
      )
    end
  end
end
