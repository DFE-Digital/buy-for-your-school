module AllCasesSurvey
  class OutcomeAchievedForm < BaseForm
    attr_accessor :outcome_achieved

    def initialize(attributes = {})
      super
      @outcome_achieved ||= all_cases_survey_response.outcome_achieved
    end

    def outcome_achieved_options
      @outcome_achieved_options ||= AllCasesSurveyResponse.outcome_achieveds.keys.reverse
    end
  end
end
