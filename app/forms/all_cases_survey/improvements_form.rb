module AllCasesSurvey
  class ImprovementsForm < BaseForm
    attr_accessor :improve_text

    def initialize(attributes = {})
      super
      @improve_text ||= all_cases_survey_response.improve_text
    end
  end
end
