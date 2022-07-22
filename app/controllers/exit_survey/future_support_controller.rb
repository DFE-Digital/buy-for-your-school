class ExitSurvey::FutureSupportController < ApplicationController
  skip_before_action :authenticate_user!

  before_action :form, only: %i[update]

  def edit
    @form = ExitSurvey::FutureSupportForm.new
  end

  def update
    if validation.success?
      exit_survey_response.update!(**form.data)
      redirect_to edit_exit_survey_hear_about_service_path(exit_survey_response)
    else
      render :edit
    end
  end

private

  def exit_survey_response
    @exit_survey_response = ExitSurveyResponse.find_by(id: params[:id])
  end

  # @return [FutureSupportForm] form object populated with validation messages
  def form
    @form =
      ExitSurvey::FutureSupportForm.new(
        messages: validation.errors(full: true).to_h,
        **validation.to_h,
      )
  end

  def form_params
    params.require(:future_support_form).permit(*%i[
      future_support
    ])
  end

  # @return [FutureSupportFormSchema] validated form input
  def validation
    ExitSurvey::FutureSupportFormSchema.new.call(**form_params)
  end
end
