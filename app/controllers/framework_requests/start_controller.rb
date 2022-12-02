module FrameworkRequests
  class StartController < ApplicationController
    skip_before_action :authenticate_user!

    def create
      framework_request = FrameworkRequest.create!
      session[:framework_request_id] = framework_request.id

      request.current_user_journey.try(:update!, framework_request:)

      redirect_to current_user.guest? ? energy_request_framework_requests_path : confirm_sign_in_framework_requests_path
    end
  end
end
