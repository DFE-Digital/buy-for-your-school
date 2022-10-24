module FrameworkRequests
  class StartController < ApplicationController
    skip_before_action :authenticate_user!

    def create
      redirect_to current_user.guest? ? sign_in_framework_requests_path : confirm_sign_in_framework_requests_path
    end
  end
end
