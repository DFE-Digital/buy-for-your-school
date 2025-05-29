class CustomerSatisfactionSurveysController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    @customer_satisfaction_survey = CustomerSatisfactionSurveyResponse.create!(form_params)
    @customer_satisfaction_survey.start_survey!
    @survey_flow = CustomerSatisfactionSurveysFlow.new(@customer_satisfaction_survey.service)
    redirect_to_path(@survey_flow.current_path, @customer_satisfaction_survey)
  end

private

  def form_params
    params.permit(:service, :source, :referer)
  end

  def redirect_to_path(path, survey)
    redirect_to Rails.application.routes.url_helpers
      .public_send(path, survey)
  end
end
