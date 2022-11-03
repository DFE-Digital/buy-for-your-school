module AllCasesSurvey
  class SatisfactionController < BaseController
    before_action :case_state, only: %i[edit]

    def edit
      save_with_param if params[:satisfaction_level]
    end

    def update
      if @form.valid?
        @form.start_survey!(request.remote_ip)
        @form.save!
        redirect_to redirect_path
      else
        render :edit
      end
    end

    def case_state
      @case_state ||= form.case_state
    end

  private

    def save_with_param
      @form.satisfaction_level = params[:satisfaction_level]
      if @form.valid?
        @form.start_survey!(request.remote_ip)
        @form.save!
        redirect_to redirect_path
      else
        render :edit
      end
    end

    def form
      @form ||= AllCasesSurvey::SatisfactionForm.new(form_params)
    end

    def form_params
      super.merge(
        params.fetch(:satisfaction_form, {}).permit(:satisfaction_level),
      )
    end

    def redirect_path
      edit_all_cases_survey_satisfaction_reason_path
    end

    def back_url
      @back_url = all_cases_survey_start_path
    end
  end
end
