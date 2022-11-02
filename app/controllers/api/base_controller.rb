module Api
  class BaseController < ApplicationController
    before_action :authenticate_api_user!

    skip_before_action :authenticate_user!
    skip_before_action :verify_authenticity_token

    def auth
      render json: { status: "OK" }, status: :ok
    end

  private

    def authenticate_api_user!
      authenticate_or_request_with_http_token do |token, _options|
        token == ENV["FAF_WEBHOOK_SECRET"]
      end
    end
  end
end
