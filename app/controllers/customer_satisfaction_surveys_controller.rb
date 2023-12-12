class CustomerSatisfactionSurveysController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    @customer_satisfaction_survey = CustomerSatisfactionSurveyResponse.create!
    @customer_satisfaction_survey.start_survey!
    redirect_to edit_customer_satisfaction_surveys_satisfaction_level_path(@customer_satisfaction_survey)
  end
end
