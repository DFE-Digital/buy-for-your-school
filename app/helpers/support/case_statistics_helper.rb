module Support
  module CaseStatisticsHelper
    def filtered_cases_path(tower, filter_attributes = {})
      if tower.nil?
        support_cases_path(anchor: "all-cases", filter_all_cases_form: filter_attributes.merge(override: true))
      elsif tower == "no-tower"
        support_cases_path(anchor: "all-cases", filter_all_cases_form: filter_attributes.merge(tower: "no-tower", override: true))
      elsif tower == "triage-tower"
        support_cases_path(anchor: "triage-cases", filter_triage_cases_form: filter_attributes.merge(override: true))
      else
        tower_tab_id = "#{tower.title.parameterize}-tower"
        filter_param_key = "filter_#{tower.title.parameterize(separator: '_')}_cases"
        support_cases_path(anchor: tower_tab_id, tower: { tower_tab_id => { filter_param_key => filter_attributes.merge(override: true) } })
      end
    end

    def top_level_stage(stage)
      Support::ProcurementStage.where(stage:)
    end

    def substage_ids_for_stage(stage)
      Support::ProcurementStage.substages_for_stage(stage).map(&:id)
    end

    def filter_cases_params(attributes = {})
      { filter_cases: attributes }
    end

    def show_all_case_workers_link
      unless session[:stats_selected_caseworker].nil?
        govuk_link_to(I18n.t("support.case_statistics.selected_caseworker.show_all"),
                      request.params.merge(selected_caseworker: "all"), no_visited_state: true)

      end
    end
  end
end
