class UsabilitySurveysController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @usability_survey = UsabilitySurveyResponse.new(service: params[:service])
    @decoded_url = decode_return_url
  end

  def create
    respond_to do |format|
      format.html do
        @usability_survey = UsabilitySurveyResponse.new(usability_survey_params)
        @usability_survey.service ||= usability_survey_params[:service]
        @decoded_url = decode_return_url
        if @usability_survey.save
          redirect_to @decoded_url || root_path, allow_other_host: true
        else
          render :new
        end
      end
    end
  end

private

  def usability_survey_params
    params.fetch(:usability_survey, {}).permit(:service, :usage_reason_other, :service_helpful, :service_not_helpful_reason, :improvements, usage_reasons: [])
  end

  def decode_return_url
    return nil unless params[:return_url]

    UrlVerifier.verify_url(params[:return_url])
  end
end
