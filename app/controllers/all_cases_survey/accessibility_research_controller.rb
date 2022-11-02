module AllCasesSurvey
  class AccessibilityResearchController < BaseController
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
      @form ||= AllCasesSurvey::AccessibilityResearchForm.new(form_params)
    end

    def form_params
      super.merge(
        params.fetch(:accessibility_research_form, {}).permit(:accessibility_research_opt_in),
      )
    end

    def redirect_path
      all_cases_survey_thank_you_path
    end

    def back_url
      @back_url = edit_all_cases_survey_improvement_path
    end
  end
end
