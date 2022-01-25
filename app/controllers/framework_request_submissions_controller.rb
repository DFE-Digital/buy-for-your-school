# frozen_string_literal: true

# :nocov:
class FrameworkRequestSubmissionsController < ApplicationController
  def update
    unless framework_request.submitted?
      SubmitFrameworkRequest.new(request: framework_request, referer: session[:faf_referer]).call
    end

    session.delete(:faf_referer)

    redirect_to framework_request_submission_path(framework_request)
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
# :nocov:
