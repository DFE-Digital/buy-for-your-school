# frozen_string_literal: true
module Support
  class SessionsController < ApplicationController
    skip_before_action :authenticate_agent!

    # @see CreateAgent
    # @see AgentSession
    def create
      agent_session.persist_successful_dfe_support_sign_in_claim!(auth: auth_hash)
      agent_session.invalidate_other_agent_sessions(auth: auth_hash)

      # TODO: add functionality to update dsi account record
      CreateAgent.new(auth: auth_hash).call

      # TODO: redirect post login based on user role
      # if current_user.buyer?
      redirect_to support_cases_path
      # elsif current_user.agent?
      #   redirect_to support_admin_path
      # end
    end

    def failure
      # DSI: report the DSI agent uid in the session if it exists
      Rollbar.error("Sign in failed unexpectedly", dfe_sign_in_uid: session[:dfe_sign_in_uid])

      # DSI: users would need to signout manually to proceed otherwise
      if session.destroy
        redirect_to support_sign_in_path, notice: I18n.t("banner.session.failure")
      end
    end

    # Redirect to root possibly via DFE_SIGN_IN_ISSUER
    #
    # @see AgentSession
    def destroy
      issuer_url = agent_session.sign_out_url.dup
      agent_session.delete!

      if issuer_url
        redirect_to issuer_url
      else
        redirect_to support_sign_in_path, notice: I18n.t("banner.session.destroy")
      end
    end

    private

    def agent_session
      AgentSession.new(session: session, redirect_url: support_issuer_redirect_url)
    end

    # @return [OmniAuth::AuthHash]
    #
    def auth_hash
      request.env["omniauth.auth"]
    end
  end
end