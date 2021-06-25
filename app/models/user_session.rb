class UserSession
  include Rails.application.routes.url_helpers

  attr_accessor :session

  def initialize(session:)
    self.session = session
  end

  def persist_successful_dfe_sign_in_claim!(omniauth_hash:)
    session[:dfe_sign_in_uid] = omniauth_hash.fetch("uid")
    session[:dfe_sign_in_sign_out_token] = omniauth_hash.dig("credentials", "id_token")
  end

  def repudiate!
    session.delete(:dfe_sign_in_uid)
    session.delete(:dfe_sign_in_sign_out_token)
  end

  def should_be_signed_out_of_dsi?
    session.key?(:dfe_sign_in_sign_out_token) && session[:dfe_sign_in_sign_out_token].present?
  end

  def sign_out_url
    return root_path unless should_be_signed_out_of_dsi?

    query = {
      post_logout_redirect_uri: auth_dfe_signout_url,
      id_token_hint: session[:dfe_sign_in_sign_out_token],
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

    redis_session_lookup.set(session_lookup_key, session.id.private_id)
  end
end
