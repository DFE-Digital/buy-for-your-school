# frozen_string_literal: true

module Support
  class CaseFilterForm
    extend Dry::Initializer[undefined: false]
    include Concerns::ValidatableForm

    option :state, optional: true
    option :category, optional: true
    option :agent, optional: true
    option :tower, optional: true
    option :stage, optional: true
    option :level, optional: true
    option :has_org, Types::Params::Bool, optional: true
    option :user_submitted, optional: true, default: proc { false }
    option :sort, ->(value) { value.compact_blank! }, optional: true, default: proc { { "action" => "descending" } }
    option :defaults, optional: true, default: proc { {} }

    # Potentially pre-scope results with as scope / query
    option :base_cases, optional: true, default: proc { Case.where(nil) }

    def initialize(**args)
      super(**args)
      set_defaults
    end

    def results
      # Default to not showing closed cases but allow explicit selection of it
      @base_cases = @base_cases.not_closed unless state == "closed"

      filtered_cases = Support::FilterCases.new(base_cases:).filter(state:, category:, agent:, tower:, stage:, level:, has_org:)
      Support::SortCases.new(filtered_cases).sort(sort)
    end

    def user_submitted?
      user_submitted != false
    end

    def filters_selected?
      filter_fields = self.class.dry_initializer.attributes(self).except(:base_cases, :messages, :sort, :user_submitted, :defaults).compact_blank
      return false if filter_fields.blank?

      filter_fields != defaults.symbolize_keys
    end

    def case_states
      Support::Case.states.keys.unshift("live")
        .map { |key| OpenStruct.new(title: I18n.t("support.case.label.state.state_#{key.downcase}"), id: key) }
    end

    def agents
      @agents ||= Support::Agent.caseworkers.by_first_name.map { |a| AgentPresenter.new(a) }
    end

    def categories
      @categories ||= (tower.present? ? Support::Category.where(support_tower_id: tower) : base_cases.joins(:category))
        .select("support_categories.id, CASE WHEN support_categories.archived THEN '(archived) '||support_categories.title ELSE support_categories.title END")
        .order("support_categories.archived ASC, support_categories.title")
        .uniq
    end

    def towers
      @towers ||= (Support::Tower.unique_towers << Support::Tower.nil_tower)
    end

    def stages
      @stages ||= TowerCase.stages.keys
        .map { |key| OpenStruct.new(title: I18n.t("support.case_statistics.stages.#{key.downcase}"), id: key) }
    end

    def levels
      @levels ||= TowerCase.support_levels.keys
        .map { |key| OpenStruct.new(title: I18n.t("support.case_statistics.support_levels.#{key}"), id: key) }
    end

  private

    def set_defaults = defaults.each { |k, v| instance_variable_set("@#{k}", v) unless instance_variable_get("@#{k}") }
  end
end
