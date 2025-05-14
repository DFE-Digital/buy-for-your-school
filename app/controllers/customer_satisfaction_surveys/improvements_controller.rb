class CustomerSatisfactionSurveys::ImprovementsController < CustomerSatisfactionSurveys::BaseController

  def update
    @customer_satisfaction_survey.attributes = form_params
    if @customer_satisfaction_survey.valid?
      @customer_satisfaction_survey.save!
      redirect_path
    else
      render :edit
    end
  end

private

  def form_params
    params.fetch(:customer_satisfaction_survey, {}).permit(:improvements)
  end

  def redirect_path
    if session[:net_promoter_score].present?
      redirect_to edit_customer_satisfaction_surveys_research_opt_in_path(@customer_satisfaction_survey)
    else
      redirect_to_path(@survey_flow.next_path, @customer_satisfaction_survey )
    end
  end
end
