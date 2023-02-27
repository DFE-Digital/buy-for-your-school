module CaseManagement
  class HandleMessages
    def received_email_attached_to_case(payload)
      Support::Case.find(payload[:support_case_id]).update!(action_required: true)
    end
  end
end
