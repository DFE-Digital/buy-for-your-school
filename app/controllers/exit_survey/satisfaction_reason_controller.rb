class ExitSurvey::SatisfactionReasonController < ApplicationController
  skip_before_action :authenticate_user!

  before_action :form, only: %i[update]

  def edit
    @form = ExitSurvey::SatisfactionForm.new(exit_survey_response)
  end

  def update
    if validation.success?
      exit_survey_response.update!(**form.data)
      redirect_to edit_exit_survey_saved_time_path(exit_survey_response)
    else
      render :edit
    end
  end

private

  def exit_survey_response
    @exit_survey_response = ExitSurveyResponsePresenter.new(ExitSurveyResponse.find_by(id: params[:id]))
  end

  # @return [SatisfactionReasonForm] form object populated with validation messages
  def form
    @form =
      ExitSurvey::SatisfactionReasonForm.new(
        messages: validation.errors(full: true).to_h,
        **validation.to_h,
      )
  end

  def form_params
    params.require(:satisfaction_reason_form).permit(*%i[
      satisfaction_text
    ])
  end

  # @return [SatisfactionReasonFormSchema] validated form input
  def validation
    ExitSurvey::SatisfactionReasonFormSchema.new.call(**form_params)
  end
end
