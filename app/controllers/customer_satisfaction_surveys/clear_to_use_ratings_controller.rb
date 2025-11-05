class CustomerSatisfactionSurveys::ClearToUseRatingsController < CustomerSatisfactionSurveys::BaseController
  def update
    @customer_satisfaction_survey.attributes = form_params
    if @customer_satisfaction_survey.valid?(:clear_to_use_rating)
      @customer_satisfaction_survey.save!
      redirect_path
    else
      render :edit
    end
  end

private

  def form_params
    params.fetch(:customer_satisfaction_survey, {}).permit(:clear_to_use_rating)
  end

  def redirect_path
    if session[:net_promoter_score].present?
      redirect_to edit_customer_satisfaction_surveys_recommendation_likelihood_path(@customer_satisfaction_survey)
    else
      redirect_to_path(@survey_flow.next_path, @customer_satisfaction_survey)
    end
  end
end
