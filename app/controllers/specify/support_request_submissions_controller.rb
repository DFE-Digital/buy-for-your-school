# frozen_string_literal: true

# Handles the submission of a support request via form
class Specify::SupportRequestSubmissionsController < Specify::ApplicationController
  def update
    unless support_request.submitted?
      SubmitSupportRequest.new(request: support_request).call
    end

    redirect_to support_request_submission_path(support_request)
  end

  def show
    if support_request.submitted?
      @support_request = SupportRequestPresenter.new(support_request)
    else
      redirect_to support_request_path(support_request)
    end
  end

private

  def support_request
    ::SupportRequest.find(params[:id])
  end
end
