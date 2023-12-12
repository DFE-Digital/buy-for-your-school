class CustomerSatisfactionSurveys::BaseController < ApplicationController
  skip_before_action :authenticate_user!

  before_action :customer_satisfaction_survey
  before_action :redirect_if_completed

private

  def customer_satisfaction_survey
    @customer_satisfaction_survey = CustomerSatisfactionSurveyResponse.find_by(id: params[:id])
  end

  def redirect_if_completed
    redirect_to customer_satisfaction_surveys_thank_you_path, notice: "Survey already completed" if @customer_satisfaction_survey.completed?
  end
end
