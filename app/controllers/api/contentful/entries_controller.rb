class Api::Contentful::EntriesController < ApplicationController
  skip_before_action :authenticate_user!
  http_basic_authenticate_with name: "api", password: ENV["CONTENTFUL_WEBHOOK_API_KEY"]
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
end
