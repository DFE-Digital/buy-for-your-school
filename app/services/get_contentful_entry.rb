class GetContentfulEntry
  class EntryNotFound < StandardError; end

  attr_accessor :entry_id

  def initialize(entry_id:, contentful_connector: ContentfulConnector.new)
    self.entry_id = entry_id
    @contentful_connector = contentful_connector
  end

  def call
    if cache_hit?
      entry = find_and_build_from_cache
    else
      entry = @contentful_connector.get_entry_by_id(entry_id)
      store_in_cache(raw_contentful_response: entry)
    end

    if entry.nil?
      send_rollbar_warning
      raise EntryNotFound
    end

    entry
  end

  private

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

  def cache_ttl
    ENV.fetch("CONTENTFUL_ENTRY_CACHING_TTL", 172_800) # 48 hours
  end

  def find_in_cache
    redis_cache.get(cache_key)
  end

  def store_in_cache(raw_contentful_response:)
    return unless ENV["CONTENTFUL_ENTRY_CACHING"] == "true"
    return unless raw_contentful_response.present? &&
      raw_contentful_response.respond_to?(:raw)

    redis_cache.set(cache_key, raw_contentful_response.raw)
    redis_cache.expire(cache_key, cache_ttl)
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
