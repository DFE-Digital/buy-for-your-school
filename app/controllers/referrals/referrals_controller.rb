module Referrals
  class ReferralsController < ApplicationController
    skip_before_action :authenticate_user!

    def rfh
      redirect_to framework_requests_path
    end

    def specify
      redirect_to root_path
    end

    def faf
      session_id = SecureRandom.uuid
      request.current_user_journey.try(:update!, session_id:)
      redirect_to faf_path(session_id)
    end

  private

    def faf_path(session_id)
      params = "?sessionId=#{session_id}"
      return "https://s107t01-webapp-v2-01.azurewebsites.net/#{params}" unless Rails.env.production?

      "https://find-dfe-approved-framework.service.gov.uk/#{params}"
    end
  end
end
