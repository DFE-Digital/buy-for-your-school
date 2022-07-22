class ExitSurvey::ThankYouController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    @exit_survey_response = ExitSurveyResponse.find_by(id: params[:id])
  end
end
