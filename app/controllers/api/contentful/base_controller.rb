class Api::Contentful::BaseController < ApplicationController
  before_action :authenticate_api_user!

  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

private

  def authenticate_api_user!
    authenticate_or_request_with_http_token do |token, _options|
      token == ENV["CONTENTFUL_WEBHOOK_API_KEY"]
    end
  end
end
