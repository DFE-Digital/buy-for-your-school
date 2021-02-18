module RedisCache
  class << self
    def redis
      @redis ||= if Rails.env.test?
        MockRedis.new
      else
        Redis::Namespace.new(
          "buy_for_your_school",
          redis: Redis.new(url: ENV["REDIS_URL"], db: 1)
        )
      end
    end
  end
end
