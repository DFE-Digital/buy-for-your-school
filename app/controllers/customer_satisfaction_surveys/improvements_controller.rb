class CustomerSatisfactionSurveys::ImprovementsController < CustomerSatisfactionSurveys::BaseController
  before_action :back_url

  def update
    @customer_satisfaction_survey.attributes = form_params
    if @customer_satisfaction_survey.valid?
      @customer_satisfaction_survey.save!
      redirect_to redirect_path
    else
      render :edit
    end
  end

private

  def form_params
    params.fetch(:customer_satisfaction_survey, {}).permit(:improvements)
  end

  def redirect_path
    return edit_customer_satisfaction_surveys_research_opt_in_path(@customer_satisfaction_survey) if session[:net_promoter_score].present?

    edit_customer_satisfaction_surveys_easy_to_use_rating_path(@customer_satisfaction_survey)
  end

  def back_url
    @back_url = edit_customer_satisfaction_surveys_recommendation_likelihood_path(@customer_satisfaction_survey)
  end
end
