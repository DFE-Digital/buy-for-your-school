class CustomerSatisfactionSurveys::SatisfactionReasonsController < CustomerSatisfactionSurveys::BaseController
  before_action :back_url

  def update
    @customer_satisfaction_survey.attributes = form_params
    if @customer_satisfaction_survey.valid?
      @customer_satisfaction_survey.save!
      @customer_satisfaction_survey.complete_survey! if session[:net_promoter_score].blank?
      redirect_to redirect_path
    else
      render :edit
    end
  end

private

  def form_params
    params.fetch(:customer_satisfaction_survey, {}).permit(:satisfaction_text)
  end

  def redirect_path
    return edit_customer_satisfaction_surveys_easy_to_use_rating_path(@customer_satisfaction_survey) if session[:net_promoter_score].present?

    customer_satisfaction_surveys_thank_you_path
  end

  def back_url
    @back_url = edit_customer_satisfaction_surveys_satisfaction_level_path(@customer_satisfaction_survey)
  end
end
