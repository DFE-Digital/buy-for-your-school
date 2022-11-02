module AllCasesSurvey
  class AboutOutcomesController < BaseController
  private

    def form
      @form ||= AllCasesSurvey::AboutOutcomesForm.new(form_params)
    end

    def form_params
      super.merge(
        params.fetch(:about_outcomes_form, {}).permit(:about_outcomes_text),
      )
    end

    def redirect_path
      edit_all_cases_survey_improvement_path
    end

    def back_url
      @back_url = edit_all_cases_survey_outcome_achieved_path
    end
  end
end
