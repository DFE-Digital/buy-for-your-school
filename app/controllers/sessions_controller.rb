# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    # This is defined by the class name of our Omniauth strategy
    redirect_to "/auth/dfe"
  end

  def create
    flash[:success] = "You have signed in as DSI user: #{dfe_sign_in_uid}."
    redirect_to new_journey_path
  end

  def failure
    Rollbar.error("Sign in failed unexpectedly")
  end

  private def auth_hash
    request.env["omniauth.auth"]
  end

  private def dfe_sign_in_uid
    auth_hash["uid"]
  end
end
