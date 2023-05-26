module CaseManagement
  class UpdateCaseSupportLevel
    include Wisper::Publisher

    def call(case_id:, agent_id:, level:)
      support_case = Support::Case.find(support_case_id)
      support_case.update!(support_level: level)

      broadcast(:case_support_level_changed, {
        case_id:,
        agent_id:,
        level:,
      })
    end
  end
end
