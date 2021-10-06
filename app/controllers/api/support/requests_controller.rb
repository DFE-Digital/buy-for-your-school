# frozen_string_literal: true

class Api::Support::RequestsController < ApplicationController
  def create
    return if support_request.submitted?

    SubmitSupportRequest.new(request: support_request).call

    support_request.update!(submitted: true)
  end

private

  def support_request
    ::SupportRequest.find(params[:id])
  end
end
