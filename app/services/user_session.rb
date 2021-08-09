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

  # Stores user sign-in information in the session.
  #
  # @param [Hash] omniauth_hash
  #
  # @return [String]
  def persist_successful_dfe_sign_in_claim!(omniauth_hash:)
    @session[:dfe_sign_in_uid] = omniauth_hash.fetch("uid")
    @session[:dfe_sign_in_sign_out_token] = omniauth_hash.dig("credentials", "id_token")
  end

  # Removes user sign-in information from the session.
  #
  # @return [Nil]
  def delete!
    @session.delete(:dfe_sign_in_uid)
    @session.delete(:dfe_sign_in_sign_out_token)
  end

  # Session includes a DSI "id_token"
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

    "#{ENV.fetch('DFE_SIGN_IN_ISSUER')}/session/end?#{query.to_query}"
  end

  # Sign out concurrent logins
  #
  # When the same DfE Sign-in user is signed into our service, invalidate the
  # first one, effectively signing it out.
  #
  # We can't manipulate the key the redis_store gem sets as the session key as:
  # redis:6379:2:2488646bef3bd44839efdb874fd133d578d729fb87fb004dd24a7e91cb3a3d62
  #
  def invalidate_other_user_sessions(omniauth_hash:)
    redis_sessions = RedisSessions.redis
    redis_session_lookup = RedisSessionLookup.redis
    dfe_sign_in_uid = omniauth_hash.fetch("uid")
    session_lookup_key = "user_dsi_id:#{dfe_sign_in_uid}"

    existing_redis_session_key = redis_session_lookup.get(session_lookup_key)
    if existing_redis_session_key
      redis_sessions.del("session:#{existing_redis_session_key}")
    end

    redis_session_lookup.set(session_lookup_key, @session.id.private_id)
  end
end
