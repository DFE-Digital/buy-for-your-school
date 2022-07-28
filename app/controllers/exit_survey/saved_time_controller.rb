class ExitSurvey::SavedTimeController < ApplicationController
  skip_before_action :authenticate_user!

  before_action :form, only: %i[update]

  def edit
    @form = ExitSurvey::SavedTimeForm.new(**exit_survey_response.to_h.compact)
    @back_url = edit_exit_survey_satisfaction_reason_path
  end

  def update
    if validation.success?
      exit_survey_response.update!(**form.data)
      redirect_to edit_exit_survey_better_quality_path(exit_survey_response)
    else
      render :edit
    end
  end

private

  def exit_survey_response
    @exit_survey_response = ExitSurveyResponse.find_by(id: params[:id])
  end

  # @return [SavedTimeForm] form object populated with validation messages
  def form
    @form =
      ExitSurvey::SavedTimeForm.new(
        messages: validation.errors(full: true).to_h,
        **validation.to_h,
      )
  end

  def form_params
    params.require(:saved_time_form).permit(*%i[
      saved_time
    ])
  end

  # @return [SavedTimeFormSchema] validated form input
  def validation
    @validation ||= ExitSurvey::SavedTimeFormSchema.new.call(**form_params)
  end
end
