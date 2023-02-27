module CaseManagement
  class HandleMessages
    include Wisper::Publisher

    def received_email_attached_to_case(payload)
      support_case = Support::Case.find(payload[:support_case_id])
      support_case.update!(action_required: true)

      if support_case.resolved?
        support_case.open!
        broadcast(:case_reopened_due_to_received_email, payload)
      end
    end
  end
end
