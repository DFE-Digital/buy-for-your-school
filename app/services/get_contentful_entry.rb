class GetContentfulEntry
  class EntryNotFound < StandardError; end

  attr_accessor :entry_id, :cache

  def initialize(entry_id:, contentful_connector: ContentfulConnector.new)
    self.entry_id = entry_id
    @contentful_connector = contentful_connector
    self.cache = Cache.new(
      enabled: ENV.fetch("CONTENTFUL_ENTRY_CACHING"),
      key: "contentful:entry:#{entry_id}",
      ttl: ENV.fetch("CONTENTFUL_ENTRY_CACHING_TTL", 172_800) # 48 hours
    )
  end

  def call
    if cache.hit?
      entry = find_and_build_from_cache
    else
      entry = @contentful_connector.get_entry_by_id(entry_id)
      store_in_cache(entry: entry)
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

  def store_in_cache(entry:)
    return unless entry.present? && entry.respond_to?(:raw)

    cache.set(value: JSON.dump(entry.raw.to_json))
  end

  def load_from_cache
    # rubocop:disable Security/JSONLoad
    serialised_json_string = cache.get
    unserialised_json_string = JSON.restore(serialised_json_string)
    JSON.parse(unserialised_json_string)
    # rubocop:enable Security/JSONLoad
  end

  def find_and_build_from_cache
    Contentful::ResourceBuilder.new(load_from_cache).run
  end
end
