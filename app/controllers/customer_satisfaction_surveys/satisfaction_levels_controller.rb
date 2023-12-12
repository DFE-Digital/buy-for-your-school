class CustomerSatisfactionSurveys::SatisfactionLevelsController < CustomerSatisfactionSurveys::BaseController
  def edit
    update if form_params.present?
  end

  def update
    @customer_satisfaction_survey.attributes = form_params
    if @customer_satisfaction_survey.valid?(:satisfaction_level)
      @customer_satisfaction_survey.save!
      @customer_satisfaction_survey.start_survey!
      redirect_to edit_customer_satisfaction_surveys_satisfaction_reason_path(@customer_satisfaction_survey)
    else
      render :edit
    end
  end

private

  def form_params
    params.fetch(:customer_satisfaction_survey, {}).permit(:satisfaction_level)
  end
end
