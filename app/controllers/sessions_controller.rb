# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_user!
  protect_from_forgery except: :bypass_callback

  # @see UserSession
  def create
    user_session.persist_successful_dfe_sign_in_claim!(omniauth_hash: auth_hash)
    user_session.invalidate_other_user_sessions(omniauth_hash: auth_hash)

    redirect_to dashboard_path
  end
  alias_method :bypass_callback, :create

  def failure
    Rollbar.error("Sign in failed unexpectedly", dfe_sign_in_uid: session[:dfe_sign_in_uid])

    # DSI: users would need to signout manually to proceed otherwise
    if session.destroy
      redirect_to root_path, notice: "Sign in failed unexpectedly, please try again"
    end
  end

  # Redirect to root possibly via DFE_SIGN_IN_ISSUER
  #
  # @see UserSession
  def destroy
    target = user_session.sign_out_url.dup
    user_session.delete!
    redirect_to target
  end

private

  def user_session
    UserSession.new(session: session)
  end

  def auth_hash
    request.env["omniauth.auth"]
  end
end
