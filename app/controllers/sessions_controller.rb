# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_user!
  protect_from_forgery except: :bypass_callback

  # @see CreateUser
  # @see UserSession
  def create
    user_session.persist_successful_dfe_sign_in_claim!(auth: auth_hash)
    user_session.invalidate_other_user_sessions(auth: auth_hash)
    user = CreateUser.new(auth: auth_hash).call

    case user
    when User
      # TODO: alternative redirect for caseworkers
      redirect_to entry_path
    when :invalid
      redirect_to root_path, notice: "Access Denied"
    when :no_organisation
      # TODO: record activity
      render "sessions/no_organisation_error"
    when :unsupported
      # TODO: record activity
      render "sessions/unsupported_organisation_error"
    end
  end
  alias_method :bypass_callback, :create

  def failure
    # DSI: report the DSI user uid in the session if it exists
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
      redirect_to exit_path, notice: I18n.t("banner.session.destroy")
    end
  end

private

  # @return [UserSession]
  def user_session
    UserSession.new(session: session, redirect_url: issuer_redirect_url)
  end

  # @return [OmniAuth::AuthHash]
  def auth_hash
    request.env["omniauth.auth"]
  end

  # @return [String, nil] "https://localhost:3000/procurement-support/new"
  # def origin
  #   request.env["omniauth.origin"]
  #   request.env["action_dispatch.request.unsigned_session_cookie"]["omniauth.origin"]
  #   request.env["rack.session"]["omniauth.origin"]
  #   request.env["omniauth.params"]
  # end

  # @return [Boolean]
  def find_framework_entrypoint?
    session[:faf_referer].present?
  end

  # Logging whilst seeking support will send the user to their profile page
  # to confirm the details before proceeding
  #
  # @return [String]
  def entry_path
    find_framework_entrypoint? ? profile_path : dashboard_path
  end

  # @return [String]
  def exit_path
    if find_framework_entrypoint?
      session.delete(:faf_referer)
      return framework_requests_path
    end

    root_path
  end
end
