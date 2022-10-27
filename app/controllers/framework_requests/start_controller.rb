module FrameworkRequests
  class StartController < ApplicationController
    skip_before_action :authenticate_user!

    def create
      framework_request = FrameworkRequest.create!
      session[:framework_request_id] = framework_request.id
      create_user_journey.update!(framework_request:)
      redirect_to current_user.guest? ? sign_in_framework_requests_path : confirm_sign_in_framework_requests_path
    end
  end
end
