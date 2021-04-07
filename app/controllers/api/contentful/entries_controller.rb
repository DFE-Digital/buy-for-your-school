class Api::Contentful::EntriesController < ApplicationController
  before_action :authenticate_api_user!

  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def changed
    Cache.delete(key: cache_key)
    render json: {status: "OK"}, status: :ok
  end

  private def cache_key
    "contentful:entry:#{changed_params["entityId"]}"
  end

  private def changed_params
    params.permit("entityId")
  end

  private def authenticate_api_user!
    authenticate_or_request_with_http_token do |token, _options|
      token == ENV["CONTENTFUL_WEBHOOK_API_KEY"]
    end
  end
end
