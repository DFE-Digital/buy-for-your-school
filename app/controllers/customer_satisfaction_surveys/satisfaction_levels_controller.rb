class CustomerSatisfactionSurveys::SatisfactionLevelsController < CustomerSatisfactionSurveys::BaseController
  def edit
    update if form_params.present?
  end

  def update
    @customer_satisfaction_survey.attributes = params_to_persist
    if @customer_satisfaction_survey.valid?(:satisfaction_level)
      @customer_satisfaction_survey.save!
      @customer_satisfaction_survey.start_survey!
      redirect_to redirect_path
    else
      render :edit
    end
  end

private

  def redirect_path
    return edit_customer_satisfaction_surveys_satisfaction_reason_path(@customer_satisfaction_survey) if @customer_satisfaction_survey.source_exit_survey?

    edit_customer_satisfaction_surveys_easy_to_use_rating_path(@customer_satisfaction_survey)
  end

  def params_to_persist
    satisfaction_level = form_params[:satisfaction_level]
    satisfaction_text = satisfaction_level.present? ? form_params["satisfaction_text_#{satisfaction_level}"] : nil

    { satisfaction_level:, satisfaction_text: }
  end

  def form_params
    satisfaction_text_params = CustomerSatisfactionSurveyResponse.satisfaction_levels.keys.map { |level| "satisfaction_text_#{level}" }
    params.fetch(:customer_satisfaction_survey, {}).permit(:satisfaction_level, satisfaction_text_params)
  end
end
