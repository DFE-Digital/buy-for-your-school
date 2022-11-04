module AllCasesSurvey
  class SatisfactionForm < BaseForm
    attr_accessor :satisfaction_level

    def initialize(attributes = {})
      super
      @satisfaction_level ||= all_cases_survey_response.satisfaction_level
    end

    def satisfaction_options
      @satisfaction_options ||= AllCasesSurveyResponse.satisfaction_levels.keys.reverse
    end
  end
end
