module AllCasesSurvey
  class AccessibilityResearchForm < BaseForm
    attr_accessor :accessibility_research_opt_in

    def initialize(attributes = {})
      super
      @accessibility_research_opt_in ||= all_cases_survey_response.accessibility_research_opt_in
    end
  end
end
