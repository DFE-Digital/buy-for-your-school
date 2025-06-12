class CustomerSatisfactionSurveysController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    @customer_satisfaction_survey = CustomerSatisfactionSurveyResponse.create!(form_params)
    @customer_satisfaction_survey.start_survey!
    @survey_flow = set_flow
    redirect_to_path(@survey_flow.current_path, @customer_satisfaction_survey)
  end

  def set_service(service)
    @service = service
    set_flow
  end

  def get_flow
    @survey_flow
  end

private

  def form_params
    params.permit(:service, :source, :referer)
  end

  def redirect_to_path(path, survey)
    redirect_to Rails.application.routes.url_helpers
      .public_send(path, survey)
  end

  def set_flow
    @service = @customer_satisfaction_survey.service if @service.blank?
    @survey_flow = CustomerSatisfactionSurveysFlow.new(@service)
  end
end
