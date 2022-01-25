# frozen_string_literal: true

# Handles the submission of a FaF support request via form
class FafsSubmissionsController < ApplicationController
  def update
    unless framework_request.submitted?
      SubmitFrameworkRequest.new(request: framework_request, referer: session[:referer]).call
    end

    redirect_to fafs_submission_path(framework_request)
  end

  def show
    if framework_request.submitted?
      @framework_request = FafPresenter.new(framework_request)
    else
      redirect_to fafs_path(framework_request)
    end
  end

private

  def framework_request
    FrameworkRequest.find(params[:id])
  end
end
