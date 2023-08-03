module CaseManagement
  class HandleMessages
    include Wisper::Publisher

    def received_email_attached_to_case(payload)
      support_case = Support::Case.find(payload[:support_case_id])
      support_case.update!(action_required: true, with_school: false)

      if support_case.may_open?
        support_case.open!
        broadcast(:case_reopened_due_to_received_email, payload)
      end
    end

    def contact_to_school_made(payload)
      support_case = Support::Case.find(payload[:support_case_id])

      if support_case.initial? && support_case.may_hold?
        support_case.hold!
        new_payload = { support_case_id: payload[:support_case_id], reason: payload[:contact_type] }
        broadcast(:case_held_by_system, new_payload)
      end
    end
  end
end
