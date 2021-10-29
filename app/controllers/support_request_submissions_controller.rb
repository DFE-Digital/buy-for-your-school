# frozen_string_literal: true

# Handles the submission of a support request via form
class SupportRequestSubmissionsController < ApplicationController
  before_action :load_support_request

  def update
    unless @support_request.submitted?
      SubmitSupportRequest.new(request: @support_request).call
    end

    redirect_to support_request_submission_path(@support_request)
  end

  def show
    unless @support_request.submitted?
      redirect_to support_request_path(@support_request)
    end
  end

private

  def load_support_request
    @support_request = SupportRequestPresenter.new(::SupportRequest.find(params[:id]))
  end
end
