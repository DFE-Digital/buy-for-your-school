module CacheableEntry
  extend ActiveSupport::Concern

  def find_and_build_entry_from_cache(cache:)
    Contentful::ResourceBuilder.new(
      load_from_cache(cache: cache)
    ).run
  end

  def store_in_cache(cache:, entry:)
    return unless entry.present? && entry.respond_to?(:raw)

    cache.set(value: JSON.dump(entry.raw.to_json))
  end

  private

  def load_from_cache(cache:)
    # rubocop:disable Security/JSONLoad
    serialised_json_string = cache.get
    unserialised_json_string = JSON.restore(serialised_json_string)
    JSON.parse(unserialised_json_string)
    # rubocop:enable Security/JSONLoad
  end
end
