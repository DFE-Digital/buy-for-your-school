module CaseStatistics
  class HandleInteractions
    def interaction_created(payload)
      Support::ActivityLogItem.create!(
        support_case_id: payload[:support_case_id],
        action: "add_interaction",
        data: { event_type: payload[:event_type] },
      )
    end
  end
end
