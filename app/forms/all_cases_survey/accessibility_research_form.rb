module AllCasesSurvey
  class AccessibilityResearchForm < BaseForm
    attr_accessor :accessibility_research_opt_in, :accessibility_research_email

    def initialize(attributes = {})
      super
      @accessibility_research_opt_in ||= all_cases_survey_response.accessibility_research_opt_in
      @accessibility_research_email ||= all_cases_survey_response.accessibility_research_email
    end
  end
end
