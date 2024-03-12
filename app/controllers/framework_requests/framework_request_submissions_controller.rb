# frozen_string_literal: true

class FrameworkRequests::FrameworkRequestSubmissionsController < FrameworkRequests::ApplicationController
  skip_before_action :authenticate_user!

  def update
    if framework_request.valid?(:complete)
      unless framework_request.submitted?
        SubmitFrameworkRequest.new(request: framework_request, referrer: session[:faf_referrer]).call
      end

      session.delete(:framework_request_id)
      session.delete(:faf_referrer)

      redirect_to framework_request_submission_path(framework_request)
    else
      redirect_to framework_request_path(framework_request)
    end
  end

  def show
    if framework_request.submitted?
      @framework_request = FrameworkRequestPresenter.new(framework_request)
    else
      redirect_to framework_request_path(framework_request)
    end
  end

private

  def framework_request
    ::FrameworkRequest.find(params[:id])
  end
end
