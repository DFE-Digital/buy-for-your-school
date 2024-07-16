# Session management logic
#
# @see SessionsController
class UserSession
  # @param session [ActionDispatch::Request::Session]
  # @param redirect_url [String] sessions#destroy
  #
  def initialize(session:, redirect_url:)
    @session = session
    @redirect_url = redirect_url
  end

  # Remove user uidn from the session
  #
  # @return [nil]
  def delete!
    dfe_sign_in_uid = @session[:dfe_sign_in_uid]
    # delete the redis session
    session_lookup_key = session_lookup_uid_key(dfe_sign_in_uid)
    redis_session_key = redis_session_lookup.get(session_lookup_key)
    if redis_session_key
      redis_sessions.del("session:#{redis_session_key}")
    end
    # delete the redis session lookup
    redis_session_lookup.del(session_lookup_key)
  end

  # Token from issuer exists in the session
  #
  #   {
  #     "uid": "",
  #     "credentials": {
  #       "id_token": "xxx"
  #     }
  #   }
  #
  # @return [Boolean]
  def should_be_signed_out_of_dsi?
    @session[:dfe_sign_in_sign_out_token].present?
  end

  # URL to end OpenID Connect issuer session
  #
  # @return [String, nil]
  def sign_out_url
    return unless should_be_signed_out_of_dsi?

    query = {
      id_token_hint: @session[:dfe_sign_in_sign_out_token],
      post_logout_redirect_uri: @redirect_url,
    }.to_query

    ::Dsi::Uri.new(subdomain: "oidc", path: "/session/end", query:).call.to_s
  end

  # Store user uid in the session
  #
  # @param auth [OmniAuth::AuthHash]
  #
  def persist_successful_dfe_sign_in_claim!(auth:)
    @session[:dfe_sign_in_uid] = auth.fetch("uid")
    @session[:dfe_sign_in_sign_out_token] = auth.dig("credentials", "id_token")
  end

  # Sign out concurrent logins
  #
  # When the same DfE Sign-in user is signed into our service, invalidate the
  # first one, effectively signing it out.
  #
  # @param auth [OmniAuth::AuthHash]
  def invalidate_other_user_sessions(auth:)
    dfe_sign_in_uid = auth.fetch("uid")
    redis_session_lookup.set(session_lookup_uid_key(dfe_sign_in_uid), @session.id.private_id)
    other_session_lookup_keys = other_session_lookups_for_user(dfe_sign_in_uid)
    other_session_lookup_keys.each do |other_session_lookup_key| # eg. session_lookup:user_dsi_id:20864786-BE4B-4BCA-9EDD-BF5A694D2AA0-s_id:2::ef4d62cce6955b726e1eb9c626cd5da0857cba47ee4d15666780dcbd2568f95b
      other_session_key = redis_session_lookup.get(other_session_lookup_key) # eg. session:2::ef4d62cce6955b726e1eb9c626cd5da0857cba47ee4d15666780dcbd2568f95b
      next unless other_session_key

      redis_session_as_string = redis_sessions.get("session:#{other_session_key}")
      next if redis_session_as_string.nil?

      # invalidate the other session: convert the session's Redis hash into a Ruby hash, set "invalidated" to true within it, convert it back into a Redis hash and save the Redis hash back into that session's row within Redis
      # rubocop is disabled as the Redis Rails sessions won't unpack into JSON without error
      # rubocop:disable Security/MarshalLoad
      other_session_hash = Marshal.load redis_session_as_string
      # rubocop:enable Security/MarshalLoad
      other_session_hash["invalidated"] = true
      redis_sessions.set("session:#{other_session_key}", Marshal.dump(other_session_hash))
    end
  end

  def redis_sessions
    RedisSessions.redis
  end

  def redis_session_lookup
    RedisSessionLookup.redis
  end

  def session_lookup_key(dfe_sign_in_uid)
    "user_dsi_id:#{dfe_sign_in_uid}"
  end

  def current_session_id_suffix
    "s_id:#{@session.id.private_id}"
  end

  def session_lookup_uid_key(dfe_sign_in_uid)
    "#{session_lookup_key(dfe_sign_in_uid)}-#{current_session_id_suffix}"
  end

  def concurrent_session_lookups_for_user(dfe_sign_in_uid)
    redis_session_lookup = RedisSessionLookup.redis
    session_lookup_key = "user_dsi_id:#{dfe_sign_in_uid}"
    concurrent_session_keys = []
    cursor = "0"
    loop do
      cursor, keys = redis_session_lookup.scan(cursor, match: "*#{session_lookup_key}*")
      concurrent_session_keys.concat(keys)
      break if cursor == "0"
    end
    concurrent_session_keys
  end

  def other_session_lookups_for_user(dfe_sign_in_uid)
    concurrent_session_lookups_for_user(dfe_sign_in_uid).reject do |concurrent_session|
      concurrent_session.include?(current_session_id_suffix)
    end
  end
end
