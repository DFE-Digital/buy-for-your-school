class ExitSurvey::OptInDetailController < ApplicationController
  skip_before_action :authenticate_user!

  before_action :form, only: %i[update]

  def edit
    @form = ExitSurvey::OptInDetailForm.new
  end

  def update
    if validation.success?
      exit_survey_response.update!(**form.data)
      redirect_to exit_survey_thank_you_path(exit_survey_response)
    else
      render :edit
    end
  end

private

  def exit_survey_response
    @exit_survey_response = ExitSurveyResponse.find_by(id: params[:id])
  end

  # @return [OptInDetailForm] form object populated with validation messages
  def form
    @form =
      ExitSurvey::OptInDetailForm.new(
        messages: validation.errors(full: true).to_h,
        **validation.to_h,
      )
  end

  def form_params
    params.require(:opt_in_detail_form).permit(*%i[
      opt_in_name opt_in_email
    ])
  end

  # @return [OptInDetailFormSchema] validated form input
  def validation
    ExitSurvey::OptInDetailFormSchema.new.call(**form_params)
  end
end
