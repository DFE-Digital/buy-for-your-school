module CaseManagement
  class UpdateCaseSummaryDetails
    include Wisper::Publisher

    def call(case_id:, agent_id:, source:, support_level:, value:)
      support_case = Support::Case.find(case_id)
      support_case.update!(
        source:,
        support_level:,
        value:,
      )

      if support_case.saved_changes.include?(:source)
        broadcast(:case_source_changed, {
          case_id:,
          agent_id:,
          source:,
        })
      end

      if support_case.saved_changes.include?(:support_level)
        broadcast(:case_support_level_changed, {
          case_id:,
          agent_id:,
          support_level:,
        })
      end

      if support_case.saved_changes.include?(:value)
        broadcast(:case_value_changed, {
          case_id:,
          agent_id:,
          procurement_value: value,
        })
      end
    end
  end
end
