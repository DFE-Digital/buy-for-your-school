class EndOfJourneySurveysController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :authenticate_feedback_from_faf!

  def new
    @end_of_journey_survey = EndOfJourneySurveyResponse.new(service: params[:service])
  end

  def create
    respond_to do |format|
      format.html do
        @end_of_journey_survey = EndOfJourneySurveyResponse.new(form_params)
        if @end_of_journey_survey.valid?
          @end_of_journey_survey.save!
          redirect_to end_of_journey_surveys_thank_you_path
        else
          render :new
        end
      end

      format.json do
        @end_of_journey_survey = EndOfJourneySurveyResponse.new(json_params)
        if @end_of_journey_survey.valid?
          @end_of_journey_survey.save!
          head :ok
        else
          head :unprocessable_entity
        end
      end
    end
  end

private

  def form_params
    params.fetch(:end_of_journey_survey, {}).permit(:easy_to_use_rating, :improvements, :service)
  end

  def json_params
    params.permit(:easy_to_use_rating, :improvements, :service)
  end

  def authenticate_feedback_from_faf!
    return unless request.format.json?

    authenticate_or_request_with_http_token do |token, _options|
      token == ENV["FAF_WEBHOOK_SECRET"]
    end
  end
end
