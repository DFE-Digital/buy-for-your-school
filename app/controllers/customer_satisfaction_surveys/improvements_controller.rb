class CustomerSatisfactionSurveys::ImprovementsController < CustomerSatisfactionSurveys::BaseController
  before_action :back_url

  def update
    @customer_satisfaction_survey.attributes = form_params
    if @customer_satisfaction_survey.valid?
      @customer_satisfaction_survey.save!
      handle_post_save_redirect
    else
      render :edit
    end
  end

private

  def form_params
    params.fetch(:customer_satisfaction_survey, {}).permit(:improvements)
  end

  def back_url
    @back_url = edit_customer_satisfaction_surveys_recommendation_likelihood_path(@customer_satisfaction_survey)
  end

  def handle_post_save_redirect
    if @customer_satisfaction_survey.service == "find_a_buying_solution"
      @customer_satisfaction_survey.complete_survey!
      redirect_to customer_satisfaction_surveys_thank_you_path
    else
      redirect_to edit_customer_satisfaction_surveys_research_opt_in_path(@customer_satisfaction_survey)
    end
  end
end
