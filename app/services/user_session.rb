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
    @session.delete(:dfe_sign_in_uid)
    @session.delete(:dfe_sign_in_sign_out_token)
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
    }

    ::Dsi::Uri.new(subdomain: "oidc", path: "/session/end", query: query).call.to_s
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
  # We can't manipulate the key the redis_store gem sets as the session key as:
  # redis:6379:2:2488646bef3bd44839efdb874fd133d578d729fb87fb004dd24a7e91cb3a3d62
  #
  # @param auth [OmniAuth::AuthHash]
  #
  def invalidate_other_user_sessions(auth:)
    redis_sessions = RedisSessions.redis
    redis_session_lookup = RedisSessionLookup.redis
    dfe_sign_in_uid = auth.fetch("uid")
    session_lookup_key = "user_dsi_id:#{dfe_sign_in_uid}"

    existing_redis_session_key = redis_session_lookup.get(session_lookup_key)
    if existing_redis_session_key
      redis_sessions.del("session:#{existing_redis_session_key}")
    end

    redis_session_lookup.set(session_lookup_key, @session.id.private_id)
  end
end
