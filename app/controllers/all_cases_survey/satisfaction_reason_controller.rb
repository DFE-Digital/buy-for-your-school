module AllCasesSurvey
  class SatisfactionReasonController < BaseController
    before_action :case_state, only: %i[edit]
    before_action :previous_satisfaction_response, only: %i[edit]

    def case_state
      @case_state ||= form.case_state
    end

    def previous_satisfaction_response
      @previous_satisfaction_response ||= form.previous_satisfaction_response
    end

  private

    def form
      @form ||= AllCasesSurvey::SatisfactionReasonForm.new(form_params)
    end

    def form_params
      super.merge(
        params.fetch(:satisfaction_reason_form, {}).permit(:satisfaction_text),
      )
    end

    def redirect_path
      form.show_outcome_questions? ? edit_all_cases_survey_outcome_achieved_path : edit_all_cases_survey_improvement_path
    end

    def back_url
      @back_url = edit_all_cases_survey_satisfaction_path
    end
  end
end
