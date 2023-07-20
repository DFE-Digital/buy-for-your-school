module CaseManagement
  class UpdateCaseSummaryDetails
    include Wisper::Publisher

    def call(case_id:, agent_id:, category_id:, query_id:, other_category:, other_query:, request_text:, source:, support_level:, value:, procurement_stage_id:)
      support_case = Support::Case.find(case_id)
      support_case.update!(
        category_id:,
        query_id:,
        other_category:,
        other_query:,
        request_text:,
        source:,
        support_level:,
        value:,
        procurement_stage_id:,
      )
      changes = support_case.saved_changes

      if changes.include?(:category_id) || changes.include?(:query_id)
        broadcast(:case_categorisation_changed, {
          case_id:,
          agent_id:,
          category_id: changes[:category_id],
          query_id: changes[:query_id],
        })
      end

      if changes.include?(:source)
        broadcast(:case_source_changed, {
          case_id:,
          agent_id:,
          source:,
        })
      end

      if changes.include?(:support_level)
        broadcast(:case_support_level_changed, {
          case_id:,
          agent_id:,
          support_level: changes[:support_level],
        })
      end

      if changes.include?(:value)
        broadcast(:case_value_changed, {
          case_id:,
          agent_id:,
          procurement_value: value,
        })
      end

      if changes.include?(:procurement_stage_id)
        broadcast(:case_procurement_stage_changed, {
          case_id:,
          agent_id:,
          procurement_stage_id: changes[:procurement_stage_id],
        })
      end
    end
  end
end
