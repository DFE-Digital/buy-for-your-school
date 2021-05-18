class WarmEntryCacheJob < ApplicationJob
  include CacheableEntry

  queue_as :caching

  # The `GetEntry` service will cache any request for an entry.
  #
  # 1. This job will request all required entries for the journey.
  # 2. If an entry is found in the cache already, nothing happens.
  # 3. If an entry is not found in the cache this job will ask
  #    Contentful for it and cache the result.
  #
  # Finder services should all use `GetEntry` in their implementations.
  def perform
    category = GetCategory.new(category_entry_id: ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"]).call
    sections = GetSectionsFromCategory.new(category: category).call
    steps = begin
      sections.map { |section| GetStepsFromSection.new(section: section).call }
    rescue GetStepsFromSection::RepeatEntryDetected
      cache.extend_ttl_on_all_entries
      return
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
