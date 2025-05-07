class CustomerSatisfactionSurveys::SatisfactionLevelsController < CustomerSatisfactionSurveys::BaseController
  before_action :back_url
  def edit
    if form_params.present?
      session[:net_promoter_score] = true
      update
    end
  end

  def update
    @customer_satisfaction_survey.attributes = params_to_persist
    if @customer_satisfaction_survey.valid?(:satisfaction_level)
      @customer_satisfaction_survey.save!
      @customer_satisfaction_survey.start_survey! if session[:net_promoter_score].present?
      @customer_satisfaction_survey.complete_survey! unless @customer_satisfaction_survey.source_exit_survey?
      redirect_to_path(@survey_flow.next_path, @customer_satisfaction_survey )
    else
      render :edit
    end
  end

private

  def redirect_path
    return edit_customer_satisfaction_surveys_satisfaction_reason_path(@customer_satisfaction_survey) if @customer_satisfaction_survey.source_exit_survey?

    customer_satisfaction_surveys_thank_you_path
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
