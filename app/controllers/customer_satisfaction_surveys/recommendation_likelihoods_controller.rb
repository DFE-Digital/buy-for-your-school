class CustomerSatisfactionSurveys::RecommendationLikelihoodsController < CustomerSatisfactionSurveys::BaseController
  def update
    @customer_satisfaction_survey.attributes = form_params
    if @customer_satisfaction_survey.valid?(:recommendation_likelihood)
      @customer_satisfaction_survey.save!
      redirect_to_path(@survey_flow.next_path,@customer_satisfaction_survey )
    else
      render :edit
    end
  end

private

  def form_params
    params.fetch(:customer_satisfaction_survey, {}).permit(:recommendation_likelihood)
  end
end
