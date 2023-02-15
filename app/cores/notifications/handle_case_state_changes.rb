module Notifications
  class HandleCaseStateChanges
    def agent_assigned_to_case(payload)
      return if payload[:assigned_to_agent_id] == payload[:assigned_by_agent_id]

      Support::Notification.case_assigned.create!(
        support_case_id: payload[:support_case_id],
        assigned_to_id: payload[:assigned_to_agent_id],
        assigned_by_id: payload[:assigned_by_agent_id],
      )
    end
  end
end
