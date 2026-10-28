module Api
  class SolutionsController < ApplicationController
    skip_before_action :authenticate_user!
    skip_before_action :verify_authenticity_token
    before_action :authenticate_api_user!

    def index
      render json: Solution.all
    end

  private

    def authenticate_api_user!
      authenticate_or_request_with_http_basic do |username, password|
        username == ENV["FLIPPER_USERNAME"] && password == ENV["FLIPPER_PASSWORD"]
      end
    end
  end
end
