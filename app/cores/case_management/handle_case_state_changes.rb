module CaseManagement
  class HandleCaseStateChanges
    def agent_assigned_to_case(payload)
      CaseManagement::OpenCase.new.call(
        support_case_id: payload[:support_case_id],
        agent_id: payload[:assigned_by_agent_id],
        reason: :agent_assigned_to_case,
      )
    end
  end
end
