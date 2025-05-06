class CustomerSatisfactionSurveys::ImprovementsController < CustomerSatisfactionSurveys::BaseController
  def update
    @customer_satisfaction_survey.attributes = form_params
    if @customer_satisfaction_survey.valid?
      @customer_satisfaction_survey.save!
      #handle_post_save_redirect
      redirect_to_path(@survey_flow.next_path,@customer_satisfaction_survey )
    else
      render :edit
    end
  end

private

  def form_params
    params.fetch(:customer_satisfaction_survey, {}).permit(:improvements)
  end

  # def handle_post_save_redirect
  #   if @customer_satisfaction_survey.service == "find_a_buying_solution"
  #     @customer_satisfaction_survey.complete_survey!
  #     redirect_to customer_satisfaction_surveys_thank_you_path
  #   else
  #     redirect_to edit_customer_satisfaction_surveys_research_opt_in_path(@customer_satisfaction_survey)
  #   end
  # end
end
