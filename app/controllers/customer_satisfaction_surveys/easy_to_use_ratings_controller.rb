class CustomerSatisfactionSurveys::EasyToUseRatingsController < CustomerSatisfactionSurveys::BaseController
  before_action :back_url

  def update
    @customer_satisfaction_survey.attributes = form_params
    if @customer_satisfaction_survey.valid?(:easy_to_use_rating)
      @customer_satisfaction_survey.save!
      redirect_to edit_customer_satisfaction_surveys_helped_how_path(@customer_satisfaction_survey)
    else
      render :edit
    end
  end

private

  def form_params
    params.fetch(:customer_satisfaction_survey, {}).permit(:easy_to_use_rating)
  end

  def back_url
    @back_url = if session[:net_promoter_score].present?
                  edit_customer_satisfaction_surveys_satisfaction_reason_path(@customer_satisfaction_survey)
                else
                  edit_customer_satisfaction_surveys_improvements_path(@customer_satisfaction_survey)
                end
  end
end
