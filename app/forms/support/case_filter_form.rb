# frozen_string_literal: true

module Support
  class CaseFilterForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :state, optional: true
    option :category, optional: true
    option :agent, optional: true
    option :tower, optional: true

    # Potentially pre-scope results with as scope / query
    option :base_cases, optional: true, default: proc { Case.where(nil) }

    def results
      # Default to not showing closed cases but allow explicit selection of it
      @base_cases = @base_cases.not_closed unless state == "closed"

      Support::FilterCases.new(base_cases:)
        .filter(state:, category:, agent:, tower:)
        .priority_ordering
    end

    def case_states
      Support::Case.states.keys
        .map { |key| OpenStruct.new(title: I18n.t("support.case.label.state.state_#{key.downcase}"), id: key) }
    end

    def agents
      @agents ||= Support::Agent.caseworkers.by_first_name.map { |a| AgentPresenter.new(a) }
    end

    def categories
      @categories ||= (tower.present? ? tower.categories : base_cases.joins(:category))
        .select("support_categories.id, support_categories.title")
        .order("support_categories.title")
        .uniq
    end

    def towers
      @towers ||= Support::Tower.unique_towers
    end
  end
end
