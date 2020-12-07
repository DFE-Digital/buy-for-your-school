class Cache
  attr_accessor :enabled, :key, :ttl
  def initialize(enabled:, key:, ttl:)
    self.enabled = enabled
    self.key = key
    self.ttl = ttl
  end

  def redis_cache
    @redis_cache ||= RedisCache.redis
  end

  def hit?
    if enabled == "true"
      redis_cache.exists?(key)
    else
      false
    end
  end

  def get
    redis_cache.get(key)
  end

  def set(value:)
    return unless enabled == "true"
    redis_cache.set(key, value)
    redis_cache.expire(key, ttl)
  end
end
