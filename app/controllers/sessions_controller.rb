# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    # This is defined by the class name of our Omniauth strategy
    redirect_to "/auth/dfe"
  end

  def create
    flash[:success] = "You have signed in as DSI user: #{dsi_uid}."
    redirect_to root_path
  end

  private def auth_hash
    request.env["omniauth.auth"]
  end

  private def dsi_uid
    auth_hash["uid"]
  end
end
