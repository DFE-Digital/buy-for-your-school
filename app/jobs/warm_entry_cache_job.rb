class WarmEntryCacheJob < ApplicationJob
  include CacheableEntry

  queue_as :caching

  def perform
    Rollbar.info("Cache warming task started…")

    category = GetCategory.new(category_entry_id: ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"]).call
    sections = GetSectionsFromCategory.new(category: category).call
    steps = begin
      sections.map { |section| GetStepsFromSection.new(section: section).call }
    rescue GetStepsFromSection::RepeatEntryDetected
      cache.extend_ttl_on_all_entries
      return
    end

    # TODO: Cache category and sections too
    [steps].flatten.each do |entry|
      store_in_cache(cache: cache, key: "contentful:entry:#{entry.id}", entry: entry)
    end

    Rollbar.info("Cache warming task complete.")
  end

  private

  def cache
    @cache ||= Cache.new(
      enabled: ENV.fetch("CONTENTFUL_ENTRY_CACHING"),
      ttl: ENV.fetch("CONTENTFUL_ENTRY_CACHING_TTL", 60 * 60 * 72)
    )
  end
end
