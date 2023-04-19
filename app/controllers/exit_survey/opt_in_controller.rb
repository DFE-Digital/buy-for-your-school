class ExitSurvey::OptInController < ApplicationController
  skip_before_action :authenticate_user!

  before_action :form, only: %i[update]

  def edit
    @form = ExitSurvey::OptInForm.new(**exit_survey_response.to_h.compact)
    @back_url = edit_exit_survey_hear_about_service_path
  end

  def update
    if validation.success?
      exit_survey_response.update!(**form.data.merge(user_ip: request.remote_ip))
      exit_survey_response.complete_survey!

      redirect_to @form.opt_in ? edit_exit_survey_opt_in_detail_path(exit_survey_response) : exit_survey_thank_you_path(exit_survey_response)
    else
      render :edit
    end
  end

private

  def exit_survey_response
    @exit_survey_response = ExitSurveyResponse.find_by(id: params[:id])
  end

  # @return [OptInForm] form object populated with validation messages
  def form
    @form =
      ExitSurvey::OptInForm.new(
        messages: validation.errors(full: true).to_h,
        **validation.to_h,
      )
  end

  def form_params
    params.require(:opt_in_form).permit(*%i[
      opt_in
    ])
  end

  # @return [OptInFormSchema] validated form input
  def validation
    @validation ||= ExitSurvey::OptInFormSchema.new.call(**form_params)
  end
end
