module Support
  module CaseSummaryHelper
    def available_sources
      I18nOption.from("support.case.label.source.%%key%%", Support::Case.sources.keys)
    end
  end
end
