class CustomerSatisfactionSurveys::SatisfactionReasonsController < CustomerSatisfactionSurveys::BaseController
  before_action :back_url

  def update
    @customer_satisfaction_survey.attributes = form_params
    if @customer_satisfaction_survey.valid?
      @customer_satisfaction_survey.save!
      redirect_to edit_customer_satisfaction_surveys_easy_to_use_rating_path(@customer_satisfaction_survey)
    else
      render :edit
    end
  end

private

  def form_params
    params.fetch(:customer_satisfaction_survey, {}).permit(:satisfaction_text)
  end

  def back_url
    @back_url = edit_customer_satisfaction_surveys_satisfaction_level_path(@customer_satisfaction_survey)
  end
end
