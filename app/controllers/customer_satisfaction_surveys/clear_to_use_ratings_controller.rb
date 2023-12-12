class CustomerSatisfactionSurveys::ClearToUseRatingsController < CustomerSatisfactionSurveys::BaseController
  before_action :back_url

  def update
    @customer_satisfaction_survey.attributes = form_params
    if @customer_satisfaction_survey.valid?(:clear_to_use_rating)
      @customer_satisfaction_survey.save!
      redirect_to edit_customer_satisfaction_surveys_recommendation_likelihood_path(@customer_satisfaction_survey)
    else
      render :edit
    end
  end

private

  def form_params
    params.fetch(:customer_satisfaction_survey, {}).permit(:clear_to_use_rating)
  end

  def back_url
    @back_url = edit_customer_satisfaction_surveys_helped_how_path(@customer_satisfaction_survey)
  end
end
