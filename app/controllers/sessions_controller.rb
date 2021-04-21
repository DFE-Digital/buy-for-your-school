# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_user!
  protect_from_forgery except: :bypass_callback

  def create
    user_session = UserSession.new(session: session)
    user_session.persist_successful_dfe_sign_in_claim!(omniauth_hash: auth_hash)
    user_session.invalidate_other_user_sessions(omniauth_hash: auth_hash)

    redirect_to dashboard_path
  end
  alias_method :bypass_callback, :create

  def failure
    Rollbar.error("Sign in failed unexpectedly")
  end

  def destroy
    user_session = UserSession.new(session: session)
    sign_out_url_copy = user_session.sign_out_url.dup

    user_session.repudiate!

    redirect_to sign_out_url_copy
  end

  private def auth_hash
    request.env["omniauth.auth"]
  end
end
