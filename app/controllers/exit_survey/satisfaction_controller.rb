class ExitSurvey::SatisfactionController < ApplicationController
  skip_before_action :authenticate_user!

  before_action :form, only: %i[update]

  def edit
    @form = ExitSurvey::SatisfactionForm.new(**exit_survey_response.to_h.compact)
    @back_url = exit_survey_start_path
  end

  def update
    if validation.success?
      exit_survey_response.update!(**form.data.merge(user_ip: request.remote_ip))
      exit_survey_response.start_survey!
      redirect_to edit_exit_survey_satisfaction_reason_path(exit_survey_response)
    else
      render :edit
    end
  end

private

  def exit_survey_response
    @exit_survey_response = ExitSurveyResponse.find_by(id: params[:id])
  end

  # @return [SatisfactionForm] form object populated with validation messages
  def form
    @form =
      ExitSurvey::SatisfactionForm.new(
        messages: validation.errors(full: true).to_h,
        **validation.to_h,
      )
  end

  def form_params
    params.require(:satisfaction_form).permit(*%i[
      satisfaction_level
    ])
  end

  # @return [SatisfactionFormSchema] validated form input
  def validation
    @validation ||= ExitSurvey::SatisfactionFormSchema.new.call(**form_params)
  end
end
