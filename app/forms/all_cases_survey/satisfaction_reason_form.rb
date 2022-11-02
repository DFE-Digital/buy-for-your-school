module AllCasesSurvey
  class SatisfactionReasonForm < BaseForm
    attr_accessor :satisfaction_text

    def initialize(attributes = {})
      super
      @satisfaction_text ||= all_cases_survey_response.satisfaction_text
    end
  end
end
