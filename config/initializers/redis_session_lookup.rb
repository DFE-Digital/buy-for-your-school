module RedisSessionLookup
  class << self
    def redis
      @redis ||=
        if Rails.env.test?
          MockRedis.new
        else
          Redis::Namespace.new(
            "session_lookup",
            redis: Redis.new(url: ENV["REDIS_URL"], db: 0),
          )
        end
    end
  end
end
