module Support
  module CaseStatisticsHelper
    def filtered_tower_path(tower, filter_attributes = {})
      if tower.nil?
        # no-tower
        support_cases_path(anchor: "all-cases", filter_all_cases_form: filter_attributes.merge(tower: "no-tower", override: true))
      else
        tower_tab_id = "#{tower.title.parameterize}-tower"
        filter_param_key = "filter_#{tower.title.parameterize(separator: '_')}_cases"
        support_cases_path(anchor: tower_tab_id, tower: { tower_tab_id => { filter_param_key => filter_attributes.merge(override: true) } })
      end
    end

    def filter_cases_params(attributes = {})
      { filter_cases: attributes }
    end
  end
end
