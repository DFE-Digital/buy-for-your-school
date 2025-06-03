class CustomerSatisfactionSurveys::BaseController < ApplicationController
  skip_before_action :authenticate_user!

  before_action :customer_satisfaction_survey
  before_action :redirect_if_completed
  before_action :set_flow
  before_action :back_url

  def set_service(service)
    @service = service
    set_flow
  end

  def get_flow
    @survey_flow
  end

private

  def customer_satisfaction_survey
    @customer_satisfaction_survey = CustomerSatisfactionSurveyResponse.find_by(id: params[:id])
  end

  def redirect_if_completed
    redirect_to customer_satisfaction_surveys_thank_you_path, notice: "Survey already completed" if @customer_satisfaction_survey.completed?
  end

  def set_flow
    @service = @customer_satisfaction_survey.service if @service.blank?
    @survey_flow = CustomerSatisfactionSurveysFlow.new(@service, current_step)
  end

  def current_step
    controller_path.split("/").last.singularize
  end

  def next_path
    @survey_flow.next_path
  end

  def back_url
    @back_url = if @survey_flow.back_path
                  Rails.application.routes.url_helpers.public_send(
                    @survey_flow.back_path,
                    @customer_satisfaction_survey,
                  )
                end
  end

  def redirect_to_path(path, survey)
    step_in_path = @survey_flow.get_step_from_path(path)

    if step_in_path == "thank_you" && !@customer_satisfaction_survey.source_exit_survey?
      @customer_satisfaction_survey.complete_survey!
    end

    if path.present?
      redirect_to Rails.application.routes.url_helpers
        .public_send(path, survey)
    end
  end
end
