class CustomerSatisfactionSurveys::ResearchOptInsController < CustomerSatisfactionSurveys::BaseController
  def update
    @customer_satisfaction_survey.attributes = form_params
    if @customer_satisfaction_survey.valid?(:research_opt_in)
      @customer_satisfaction_survey.save!
      @customer_satisfaction_survey.complete_survey!
      redirect_to_path(@survey_flow.next_path,@customer_satisfaction_survey )
    else
      render :edit
    end
  end

private

  def form_params
    params.fetch(:customer_satisfaction_survey, {}).permit(:research_opt_in, :research_opt_in_email, :research_opt_in_job_title)
  end
end
