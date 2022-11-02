module AllCasesSurvey
  class OutcomeAchievedController < BaseController
  private

    def form
      @form ||= AllCasesSurvey::OutcomeAchievedForm.new(form_params)
    end

    def form_params
      super.merge(
        params.fetch(:outcome_achieved_form, {}).permit(:outcome_achieved),
      )
    end

    def redirect_path
      edit_all_cases_survey_about_outcome_path
    end

    def back_url
      @back_url = edit_all_cases_survey_satisfaction_reason_path
    end
  end
end
