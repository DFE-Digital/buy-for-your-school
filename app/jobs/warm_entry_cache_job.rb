class WarmEntryCacheJob < ApplicationJob
  include CacheableEntry

  queue_as :caching
  sidekiq_options retry: 5

  def perform
    entries = BuildJourneyOrder.new(
      entries: GetAllContentfulEntries.new.call,
      starting_entry_id: ENV["CONTENTFUL_PLANNING_START_ENTRY_ID"]
    ).call

    entries.each do |entry|
      store_in_cache(cache: cache, key: "contentful:entry:#{entry.id}", entry: entry)
    end
  rescue BuildJourneyOrder::RepeatEntryDetected,
    BuildJourneyOrder::TooManyChainedEntriesDetected
    cache.extend_ttl_on_all_entries
  end

  private

  def cache
    @cache ||= Cache.new(
      enabled: ENV.fetch("CONTENTFUL_ENTRY_CACHING"),
      ttl: ENV.fetch("CONTENTFUL_ENTRY_CACHING_TTL", 60 * 60 * 72)
    )
  end
end
