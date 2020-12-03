class WarmEntryCacheJob < ApplicationJob
  include CacheableEntry

  queue_as :caching
  sidekiq_options retry: 5

  def perform
    entries = GetAllContentfulEntries.new.call
    entries.each do |entry|
      store_in_cache(cache: cache, key: "contentful:entry:#{entry.id}", entry: entry)
    end
  end

  private

  def cache
    @cache ||= Cache.new(
      enabled: ENV.fetch("CONTENTFUL_ENTRY_CACHING"),
      ttl: ENV.fetch("CONTENTFUL_ENTRY_CACHING_TTL", 60 * 60 * 48)
    )
  end
end
