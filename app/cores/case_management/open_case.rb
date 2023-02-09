module CaseManagement
  class OpenCase
    include Wisper::Publisher

    def call(support_case_id:, agent_id:, reason:)
      support_case = Support::Case.find(support_case_id)
      return unless support_case.may_open?

      previous_state = support_case.state
      support_case.open!

      broadcast(:case_opened, { support_case_id:, agent_id:, previous_state:, reason: })
    end
  end
end
