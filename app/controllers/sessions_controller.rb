# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    # This is defined by the class name of our Omniauth strategy
    redirect_to "/auth/dfe"
  end

  def create
    UserSession.new(session: session)
      .persist_successful_dfe_sign_in_claim!(omniauth_hash: auth_hash)

    redirect_to new_journey_path
  end

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
