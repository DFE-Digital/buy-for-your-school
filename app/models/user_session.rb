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
    session.key?(:dfe_sign_in_sign_out_token) && !session[:dfe_sign_in_sign_out_token].blank?
  end

  def sign_out_url
    return root_path unless should_be_signed_out_of_dsi?

    query = {
      post_logout_redirect_uri: auth_dfe_signout_url,
      id_token_hint: session[:dfe_sign_in_sign_out_token]
    }

    "#{ENV.fetch("DFE_SIGN_IN_ISSUER")}/session/end?#{query.to_query}"
  end
end
