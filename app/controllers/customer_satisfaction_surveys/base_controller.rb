class CustomerSatisfactionSurveys::BaseController < ApplicationController
  skip_before_action :authenticate_user!

  before_action :customer_satisfaction_survey
  before_action :redirect_if_completed
  before_action :set_flow
  before_action :back_url

private

  def customer_satisfaction_survey
    @customer_satisfaction_survey = CustomerSatisfactionSurveyResponse.find_by(id: params[:id])
  end

  def redirect_if_completed
    redirect_to customer_satisfaction_surveys_thank_you_path, notice: "Survey already completed" if @customer_satisfaction_survey.completed?
  end

  def set_flow
    @survey_flow = CustomerSatisfactionSurveysFlow.new(@customer_satisfaction_survey.service, current_step)
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

    redirect_to Rails.application.routes.url_helpers
      .public_send(path, survey)
  end
end
