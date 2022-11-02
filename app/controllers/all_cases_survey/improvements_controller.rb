module AllCasesSurvey
  class ImprovementsController < BaseController
    def update
      if @form.valid?
        @form.all_cases_survey_response.completed_status!
        @form.save!
        redirect_to redirect_path
      else
        render :edit
      end
    end

  private

    def form
      @form ||= AllCasesSurvey::ImprovementsForm.new(form_params)
    end

    def form_params
      super.merge(
        params.fetch(:improvements_form, {}).permit(:improve_text),
      )
    end

    def redirect_path
      all_cases_survey_thank_you_path
    end

    def back_url
      @back_url = form.show_outcome_questions? ? edit_all_cases_survey_about_outcome_path : edit_all_cases_survey_satisfaction_reason_path
    end
  end
end
