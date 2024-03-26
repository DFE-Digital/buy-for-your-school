module Support
  module CaseHelper
    def other_cases_by_case_org_path(case_organisation, back_to:)
      support_case_search_index_path(search_case_form: { search_term: case_organisation.name, state: Support::Case.states.keys.excluding("closed"), exact_match: true }, back_to:)
    end

    def other_cases_by_case_org_exist?(case_organisation)
      Support::Case.where(organisation: case_organisation).where.not(state: :closed).count > 1
    end
  end
end
