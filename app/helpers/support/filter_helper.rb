module Support
  module FilterHelper
    def toggle_visibility?(key)
      params[key].present? || cached_filter_params_for(key).present? ? "govuk-!-display-block" : "govuk-!-display-none"
    end

    def available_states
      I18nOption.from("support.case.label.state.state_%%key%%", Support::Case.states.keys.unshift("live"))
    end

    def available_categories(scoped_by_tower = nil)
      (scoped_by_tower.present? ? Support::Category.where(support_tower_id: scoped_by_tower) : Support::Category)
        .select("support_categories.id, CASE WHEN support_categories.archived THEN '(archived) '||support_categories.title ELSE support_categories.title END")
        .order("support_categories.archived ASC, support_categories.title")
        .uniq
    end

    def available_towers
      Support::Tower.unique_towers << Support::Tower.nil_tower
    end

    def available_agents
      Support::Agent.caseworkers.by_first_name.map { |a| Support::AgentPresenter.new(a) }
    end

    def available_stages
      I18nOption.from("support.case_statistics.stages.%%key%%", Support::TowerCase.stages.keys)
    end

    def available_levels
      I18nOption.from("support.case_statistics.support_levels.%%key%%", Support::TowerCase.support_levels.keys)
    end
  end
end
