module AllCasesSurvey
  class BaseForm
    include ActiveModel::Model

    attr_accessor :id

    def save!
      all_cases_survey_response.update!(data)
    end

    def to_h
      instance_values.symbolize_keys
    end

    def data
      to_h.except(:id, :case_id, :validation_context, :errors, :all_cases_survey_response)
    end

    def all_cases_survey_response
      @all_cases_survey_response ||= AllCasesSurveyResponsePresenter.new(AllCasesSurveyResponse.find(@id))
    end

    def show_outcome_questions?
      all_cases_survey_response.case_resolved?
    end
  end
end
