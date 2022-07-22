class ExitSurvey::BetterQualityController < ApplicationController
  skip_before_action :authenticate_user!

  before_action :form, only: %i[update]

  def edit
    @form = ExitSurvey::BetterQualityForm.new
  end

  def update
    if validation.success?
      exit_survey_response.update!(**form.data)
      redirect_to edit_exit_survey_future_support_path(exit_survey_response)
    else
      render :edit
    end
  end

private

  def exit_survey_response
    @exit_survey_response = ExitSurveyResponse.find_by(id: params[:id])
  end

  # @return [BetterQualityForm] form object populated with validation messages
  def form
    @form =
      ExitSurvey::BetterQualityForm.new(
        messages: validation.errors(full: true).to_h,
        **validation.to_h,
      )
  end

  def form_params
    params.require(:better_quality_form).permit(*%i[
      better_quality
    ])
  end

  # @return [BetterQualityFormSchema] validated form input
  def validation
    ExitSurvey::BetterQualityFormSchema.new.call(**form_params)
  end
end
