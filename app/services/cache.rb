class Cache
  attr_accessor :enabled, :key, :ttl
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
end
