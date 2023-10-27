module Support
  module CaseSummaryHelper
    def available_sources
      I18nOption.from("support.case.label.source.%%key%%", Support::Case.sources.keys)
    end

    def available_projects
      Support::Case.distinct.pluck(:project).compact
    end

    def project_grouped_options
      [["Existing projects", available_projects], ["Or", ["Add new project"]]]
    end
  end
end
