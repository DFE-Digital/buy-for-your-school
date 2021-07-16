# Fetch entries from Contentful and cache in Redis
#
class GetEntry
  class EntryNotFound < StandardError; end
  include CacheableEntry

  attr_accessor :entry_id, :cache

  # @param entry_id [String] Contentful Entry ID
  # @param contentful_connector [ContentfulConnector] Contentful API wrapper
  #
  def initialize(entry_id:, contentful_connector: ContentfulConnector.new)
    self.entry_id = entry_id
    @contentful_connector = contentful_connector
    self.cache = Cache.new(
      enabled: ENV.fetch("CONTENTFUL_ENTRY_CACHING"),
      ttl: ENV.fetch("CONTENTFUL_ENTRY_CACHING_TTL", 60 * 60 * 72),
    )
  end

  # @raise [GetEntry::EntryNotFound]
  #
  # @return [Contentful::Entry]
  #
  def call
    if cache.hit?(key: cache_key)
      entry = find_and_build_entry_from_cache(cache: cache, key: cache_key)
    else
      entry = @contentful_connector.get_entry_by_id(entry_id)
      store_in_cache(cache: cache, key: cache_key, entry: entry)
    end

    if entry.nil?
      send_rollbar_warning
      raise EntryNotFound
    end

    entry
  end

private

  # @return [String]
  def cache_key
    "#{Cache::ENTRY_CACHE_KEY_PREFIX}:#{entry_id}"
  end

  def send_rollbar_warning
    Rollbar.warning(
      "The following Contentful entry identifier could not be found.",
      contentful_url: ENV["CONTENTFUL_URL"],
      contentful_space_id: ENV["CONTENTFUL_SPACE"],
      contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
      contentful_entry_id: entry_id,
    )
  end
end
