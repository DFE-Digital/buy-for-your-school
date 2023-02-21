module Support
  module CaseStatisticsHelper
    def filtered_tower_path(tower, filter_attributes = {})
      if tower.nil?
        # no-tower
        support_cases_path(anchor: "all-cases", filter_all_cases_form: filter_attributes.merge(tower: "no-tower"))
      else
        tower_tab_id = "#{tower.title.parameterize}-tower"
        support_cases_path(anchor: tower_tab_id, tower: { tower_tab_id => { filter_cases: filter_attributes } })
      end
    end

    def filter_cases_params(attributes = {})
      { filter_cases: attributes }
    end
  end
end
