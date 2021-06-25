class Api::Contentful::EntriesController < ApplicationController
  before_action :authenticate_api_user!

  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def changed
    Rollbar.info("Accepted request to cache bust Contentful Entry", cache_key: cache_key)

    Cache.delete(key: cache_key)
    render json: { status: "OK" }, status: :ok
  end

private

  def cache_key
    "#{Cache::ENTRY_CACHE_KEY_PREFIX}:#{changed_params['entityId']}"
  end

  def changed_params
    params.permit("entityId")
  end

  def authenticate_api_user!
    authenticate_or_request_with_http_token do |token, _options|
      token == ENV["CONTENTFUL_WEBHOOK_API_KEY"]
    end
  end
end
