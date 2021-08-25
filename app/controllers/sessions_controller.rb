# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_user!
  protect_from_forgery except: :bypass_callback

  # @see UserSession
  def create
    user_session.persist_successful_dfe_sign_in_claim!(omniauth_hash: auth_hash)
    user_session.invalidate_other_user_sessions(omniauth_hash: auth_hash)

    # TODO: redirect post login based on user role
    # if current_user.buyer?
    redirect_to dashboard_path
    # elsif current_user.agent?
    #   redirect_to support_admin_path
    # end
  end
  alias_method :bypass_callback, :create

  def failure
    Rollbar.error("Sign in failed unexpectedly", dfe_sign_in_uid: session[:dfe_sign_in_uid])

    # DSI: users would need to signout manually to proceed otherwise
    if session.destroy
      redirect_to root_path, notice: I18n.t("banner.session.failure")
    end
  end

  # Redirect to root possibly via DFE_SIGN_IN_ISSUER
  #
  # @see UserSession
  def destroy
    issuer_url = user_session.sign_out_url.dup
    user_session.delete!

    if issuer_url
      redirect_to issuer_url
    else
      redirect_to root_path, notice: I18n.t("banner.session.destroy")
    end
  end

private

  def user_session
    UserSession.new(session: session, redirect_url: issuer_redirect_url)
  end

  def auth_hash
    request.env["omniauth.auth"]
  end
end
