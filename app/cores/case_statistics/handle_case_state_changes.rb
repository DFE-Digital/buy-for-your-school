module CaseStatistics
  class HandleCaseStateChanges
    def case_opened(payload)
      Support::ActivityLogItem.create!(
        support_case_id: payload[:support_case_id],
        action: "open_case",
      )
    end
  end
end
