# Cache provides the functionality for managing the Redis cache.
class Cache
  attr_accessor :enabled, :key, :ttl

  ENTRY_CACHE_KEY_PREFIX = "contentful:entry".freeze

  def initialize(enabled:, ttl:)
    self.enabled = enabled
    self.ttl = ttl
  end

  def redis_cache
    @redis_cache ||= RedisCache.redis
  end

  def hit?(key:)
    if enabled == "true"
      redis_cache.exists?(key)
    else
      false
    end
  end

  def get(key:)
    redis_cache.get(key)
  end

  def set(key:, value:)
    return unless enabled == "true"

    redis_cache.set(key, value)
    redis_cache.expire(key, ttl)
  end

  def self.delete(key:)
    RedisCache.redis.del(key)
  end

  def extend_ttl_on_all_entries(extension: (60 * 60 * 24))
    redis_cache.keys("#{Cache::ENTRY_CACHE_KEY_PREFIX}:*").map do |key|
      previous_ttl = redis_cache.ttl(key)
      extended_ttl = extension + previous_ttl

      redis_cache.expire(key, extended_ttl)
    end
  end
end
