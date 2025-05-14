class CustomerSatisfactionSurveys::ResearchOptInsController < CustomerSatisfactionSurveys::BaseController

  def update
    @customer_satisfaction_survey.attributes = form_params
    if @customer_satisfaction_survey.valid?(:research_opt_in)
      @customer_satisfaction_survey.save!
      @customer_satisfaction_survey.complete_survey! if session[:net_promoter_score].present?
      redirect_path
    else
      render :edit
    end
  end

private

  def form_params
    params.fetch(:customer_satisfaction_survey, {}).permit(:research_opt_in, :research_opt_in_email, :research_opt_in_job_title)
  end

  def redirect_path
    if session[:net_promoter_score].present?
      redirect_to customer_satisfaction_surveys_thank_you_path
    else
      redirect_to_path(@survey_flow.next_path, @customer_satisfaction_survey )
    end
  end

  def back_url
    @back_url = if session[:net_promoter_score].present?
                  edit_customer_satisfaction_surveys_improvements_path(@customer_satisfaction_survey)
                else
                  super
                end
  end
end
