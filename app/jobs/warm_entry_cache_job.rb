class WarmEntryCacheJob < ApplicationJob
  include CacheableEntry

  queue_as :caching

  # The `GetEntry` service will cache any request for an entry.
  #
  # 1. This job will request all required entries for the journey
  # 2. Make a complete copy of the cache
  # 3. Ask Contentful for all every entry and cache the result
  # 4. If it fails, revert back to the old cache with an extended TTL and probably log an error
  #
  # Finder services should all use `GetEntry` in their implementations.
  def perform
    backup_old_cache

    category = GetCategory.new(category_entry_id: ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"]).call
    sections = GetSectionsFromCategory.new(category: category).call
    tasks = sections.flat_map { |section| GetTasksFromSection.new(section: section).call }

    begin
      tasks.flat_map { |task| GetStepsFromTask.new(task: task).call }
    rescue GetStepsFromTask::RepeatEntryDetected
      restore_old_cache
      Rollbar.error("Cache warming task failed. The old cached data was extended by 24 hours.")

      return
    end

    Rollbar.info("Cache warming task complete.")
  end

private

  def cache
    @cache ||= Cache.new(
      enabled: ENV.fetch("CONTENTFUL_ENTRY_CACHING"),
      ttl: ENV.fetch("CONTENTFUL_ENTRY_CACHING_TTL", 60 * 60 * 72),
    )
  end

  def backup_old_cache
    move_cached_items(
      keys: RedisCache.redis.keys("#{Cache::ENTRY_CACHE_KEY_PREFIX}:*"),
      old_key_prefix: "#{Cache::ENTRY_CACHE_KEY_PREFIX}:",
      new_key_prefix: "backup:#{Cache::ENTRY_CACHE_KEY_PREFIX}:",
    )
  end

  def restore_old_cache
    move_cached_items(
      keys: RedisCache.redis.keys("backup:#{Cache::ENTRY_CACHE_KEY_PREFIX}:*"),
      old_key_prefix: "backup:#{Cache::ENTRY_CACHE_KEY_PREFIX}:",
      new_key_prefix: "#{Cache::ENTRY_CACHE_KEY_PREFIX}:",
    )
  end

  def move_cached_items(keys:, old_key_prefix:, new_key_prefix:)
    keys.map do |key|
      entry_id = key.sub(old_key_prefix, "")
      new_cache_key = "#{new_key_prefix}#{entry_id}"

      value = cache.get(key: key)

      cache.set(key: new_cache_key, value: value)
      Cache.delete(key: key)
    end
  end
end
