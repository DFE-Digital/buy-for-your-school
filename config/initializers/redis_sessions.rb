module RedisSessions
  class << self
    def redis
      @redis ||= if Rails.env.test?
        MockRedis.new
      else
        Redis.new(url: ENV["REDIS_URL"], db: 0)
      end
    end
  end
end
