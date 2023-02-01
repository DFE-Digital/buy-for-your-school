module FrameworkRequests
  class StartController < ApplicationController
    skip_before_action :authenticate_user!

    def create
      framework_request = FrameworkRequest.create!
      session[:framework_request_id] = framework_request.id

      request.current_user_journey.try(:update!, framework_request:)

      redirect_to Flipper.enabled?(:energy_bill_flow) ? next_step_energy_bill_flow : next_step_legacy
    end

  private

    def next_step_energy_bill_flow
      energy_request_framework_requests_path
    end

    def next_step_legacy
      current_user.guest? ? sign_in_framework_requests_path : confirm_sign_in_framework_requests_path
    end
  end
end
