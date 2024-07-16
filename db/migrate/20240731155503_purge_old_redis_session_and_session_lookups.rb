class PurgeOldRedisSessionAndSessionLookups < ActiveRecord::Migration[7.1]
  def up
    # purge all session rows from Redis
    redis_sessions = RedisSessions.redis
    sessions = redis_sessions.keys("session:*")
    redis_sessions.del(sessions) unless sessions.empty?

    # purge all session lookup rows from Redis
    redis_session_lookup = RedisSessionLookup.redis
    session_lookups = redis_session_lookup.keys("user_dsi_id:*")
    redis_session_lookup.del(session_lookups) unless session_lookups.empty?
  end

  def down
    # irreversible
  end
end
