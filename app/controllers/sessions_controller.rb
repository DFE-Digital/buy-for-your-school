# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    # This is defined by the class name of our Omniauth strategy
    redirect_to "/auth/dfe"
  end

  def create
    session[:dfe_sign_in_uid] = dfe_sign_in_uid
    flash[:success] = "You have signed in as DSI user: #{dfe_sign_in_uid}."
    redirect_to new_journey_path
  end

  def failure
    Rollbar.error("Sign in failed unexpectedly")
  end

  def destroy
    redirect_to root_path
  end

  private def auth_hash
    request.env["omniauth.auth"]
  end

  private def dfe_sign_in_uid
    auth_hash["uid"]
  end
end
