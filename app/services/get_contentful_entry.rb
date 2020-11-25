require "contentful"

class GetContentfulEntry
  class EntryNotFound < StandardError; end

  attr_accessor :entry_id

  def initialize(entry_id:)
    self.entry_id = entry_id
  end

  def call
    if cache_hit?
      entry = find_and_build_from_cache
    else
      entry = contentful_client.entry(entry_id)
      store_in_cache(raw_contentful_response: entry)
    end

    if entry.nil?
      send_rollbar_warning
      raise EntryNotFound
    end

    entry
  end

  private

  def contentful_client
    @contentful_client ||= Contentful::Client.new(
      api_url: ENV["CONTENTFUL_URL"],
      space: ENV["CONTENTFUL_SPACE"],
      environment: ENV["CONTENTFUL_ENVIRONMENT"],
      access_token: ENV["CONTENTFUL_ACCESS_TOKEN"]
    )
  end

  def send_rollbar_warning
    Rollbar.warning(
      "The following Contentful entry identifier could not be found.",
      contentful_url: ENV["CONTENTFUL_URL"],
      contentful_space_id: ENV["CONTENTFUL_SPACE"],
      contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
      contentful_entry_id: entry_id
    )
  end

  def cache_key
    @cache_key ||= "contentful:entry:#{entry_id}"
  end

  def cache_hit?
    if ENV["CONTENTFUL_ENTRY_CACHING"] == "true"
      redis_cache.exists?(cache_key)
    else
      false
    end
  end

  def find_in_cache
    redis_cache.get(cache_key)
  end

  def store_in_cache(raw_contentful_response:)
    return unless ENV["CONTENTFUL_ENTRY_CACHING"] == "true"
    return unless raw_contentful_response.present? &&
      raw_contentful_response.respond_to?(:raw)

    redis_cache.set(cache_key, raw_contentful_response.raw)
  end

  def find_and_build_from_cache
    Contentful::ResourceBuilder.new(
      JSON.parse(find_in_cache)
    ).run
  end

  def redis_cache
    RedisCache.redis
  end
end
