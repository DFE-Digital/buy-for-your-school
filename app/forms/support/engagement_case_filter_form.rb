# frozen_string_literal: true

module Support
  class EngagementCaseFilterForm < CaseFilterForm
    option :created_by, optional: true
    option :base_cases, optional: true, default: proc { Case.created_by_e_and_o }

    def results
      # Default to not showing closed cases but allow explicit selection of it
      @base_cases = @base_cases.not_closed unless state == "closed"

      filtered_cases = Support::FilterCases.new(base_cases:)
      filtered_cases.included_associations = %i[category created_by]
      Support::SortCases.new(filtered_cases.filter(state:, category:, agent:, tower:, stage:, level:, has_org:)).sort(sort)
    end
  end
end
