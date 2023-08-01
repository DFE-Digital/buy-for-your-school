module Support
  module FilterHelper
    def toggle_visibility?(key)
      params[key].present? || cached_filter_params_for(key).present? ? "govuk-!-display-block" : "govuk-!-display-none"
    end

    def available_states
      CheckboxOption
        .from(
          I18nOption.from("support.case.label.state.state_%%key%%", Support::Case.states.keys.unshift("live")),
          include_all: true,
        )
    end

    def available_categories(scoped_by_tower = nil)
      CheckboxOption
        .from(
          (scoped_by_tower.present? ? Support::Category.where(support_tower_id: scoped_by_tower) : Support::Category)
            .select("support_categories.id, CASE WHEN support_categories.archived THEN '(archived) '||support_categories.title ELSE support_categories.title END")
            .order("support_categories.archived ASC, support_categories.title")
            .uniq,
          include_all: true,
        )
    end

    def available_towers
      Support::Tower.unique_towers << Support::Tower.nil_tower
    end

    def available_agents
      CheckboxOption
        .from(
          Support::Agent.caseworkers.by_first_name.map { |a| Support::AgentPresenter.new(a) },
          title_field: :full_name,
          include_all: true,
        )
    end

    def available_stages
      I18nOption.from("support.case_statistics.stages.%%key%%", Support::TowerCase.stages.keys)
    end

    def available_procurement_stages
      CheckboxOption
        .from(
          Support::ProcurementStage.all.map { |s| Support::ProcurementStagePresenter.new(s) },
          title_field: :detailed_title_short,
          include_all: true,
          include_unspecified: true,
        )
    end

    def available_levels
      CheckboxOption
        .from(
          I18nOption.from("support.case_statistics.support_levels.%%key%%", Support::TowerCase.support_levels.keys),
          include_all: true,
        )
    end
  end
end
