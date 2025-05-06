class CustomerSatisfactionSurveys::SatisfactionReasonsController < CustomerSatisfactionSurveys::BaseController
  def update
    @customer_satisfaction_survey.attributes = form_params
    if @customer_satisfaction_survey.valid?
      @customer_satisfaction_survey.save!
      redirect_to_path(@survey_flow.next_path,@customer_satisfaction_survey )
    else
      render :edit
    end
  end

private

  def form_params
    params.fetch(:customer_satisfaction_survey, {}).permit(:satisfaction_text)
  end
end
