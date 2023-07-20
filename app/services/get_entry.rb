# Fetch entries from Contentful and cache in Redis
#
class GetEntry
  class EntryNotFound < StandardError; end

  include InsightsTrackable
  include CacheableEntry

  # @param entry_id [String] Contentful Entry ID
  # @param client [Content::Client]
  #
  def initialize(entry_id:, client: Content::Client.new)
    @entry_id = entry_id
    @client = client
    @cache = Cache.new(
      enabled: ENV.fetch("CONTENTFUL_ENTRY_CACHING"),
      ttl: ENV.fetch("CONTENTFUL_ENTRY_CACHING_TTL", 60 * 60 * 72),
    )
  end

  # @raise [GetEntry::EntryNotFound]
  #
  # @return [Contentful::Entry]
  #
  def call
    if @cache.hit?(key: cache_key)
      entry = find_and_build_entry_from_cache(cache: @cache, key: cache_key)
    else
      entry = @client.by_id(@entry_id)
      store_in_cache(cache: @cache, key: cache_key, entry:)
    end

    if entry.nil?
      track_error("GetEntry/EntryNotFound")
      raise EntryNotFound, @entry_id
    end

    entry
  end

private

  # @return [String]
  def cache_key
    "#{Cache::ENTRY_CACHE_KEY_PREFIX}:#{@entry_id}"
  end

  def tracking_base_properties
    super.merge(
      contentful_entry_id: @entry_id,
      contentful_space_id: @client.space,
      contentful_environment: @client.environment,
      contentful_url: @client.api_url,
    )
  end
end
