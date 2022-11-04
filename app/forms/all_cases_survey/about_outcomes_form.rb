module AllCasesSurvey
  class AboutOutcomesForm < BaseForm
    attr_accessor :about_outcomes_text

    def initialize(attributes = {})
      super
      @about_outcomes_text ||= all_cases_survey_response.about_outcomes_text
    end
  end
end
