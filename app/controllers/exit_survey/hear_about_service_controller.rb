class ExitSurvey::HearAboutServiceController < ApplicationController
  skip_before_action :authenticate_user!

  before_action :form, only: %i[update]

  def edit
    @form = ExitSurvey::HearAboutServiceForm.new(**exit_survey_response.to_h.compact)
    @back_url = edit_exit_survey_future_support_path
  end

  def update
    if validation.success?
      # byebug
      exit_survey_response.update!(**form.data)
      redirect_to edit_exit_survey_opt_in_path(exit_survey_response)
    else
      render :edit
    end
  end

private

  def exit_survey_response
    @exit_survey_response = ExitSurveyResponse.find_by(id: params[:id])
  end

  # @return [HearAboutServiceForm] form object populated with validation messages
  def form
    @form =
      ExitSurvey::HearAboutServiceForm.new(
        messages: validation.errors(full: true).to_h,
        **validation.to_h,
      )
  end

  def form_params
    params.require(:hear_about_service_form).permit(*%i[
      hear_about_service hear_about_service_other
    ])
  end

  # @return [HearAboutServiceFormSchema] validated form input
  def validation
    @validation ||= ExitSurvey::HearAboutServiceFormSchema.new.call(**form_params)
  end
end
