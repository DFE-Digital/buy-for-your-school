class CustomerSatisfactionSurveys::RecommendationLikelihoodsController < CustomerSatisfactionSurveys::BaseController

  def edit
    if form_params.present?
      session.delete(:net_promoter_score)
      update
    end
  end

  def update
    @customer_satisfaction_survey.attributes = form_params
    if @customer_satisfaction_survey.valid?(:recommendation_likelihood)
      @customer_satisfaction_survey.save!
      @customer_satisfaction_survey.start_survey! if session[:net_promoter_score].blank?
      redirect_to_path(@survey_flow.next_path, @customer_satisfaction_survey)
    else
      render :edit
    end
  end

private

  def form_params
    params.fetch(:customer_satisfaction_survey, {}).permit(:recommendation_likelihood)
  end

  def back_url
    if session[:net_promoter_score].present?
      @back_url = edit_customer_satisfaction_surveys_clear_to_use_rating_path(@customer_satisfaction_survey)
    else
      super
    end
  end
end
