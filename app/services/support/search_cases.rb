# frozen_string_literal: true

module Support
  class SearchCases
    def self.results(search_params)
      return if search_params.nil?

      results = search_results(search_params[:search_term])
      results = results.merge(Support::Case.by_category(search_params[:category])) if search_params[:category].present?
      results = results.merge(Support::Case.by_state(search_params[:state])) if search_params[:state].present?
      results = results.merge(Support::Case.by_agent(search_params[:agent])) if search_params[:agent].present?
      results.map(&:case)
    end

    def self.search_results(search_term)
      Support::CaseSearch.find_a_case(search_term).joins(:case)
    end
  end
end
