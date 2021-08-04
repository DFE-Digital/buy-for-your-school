# frozen_string_literal: true

class Api::Contentful::EntriesController < Api::Contentful::BaseController
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
end
