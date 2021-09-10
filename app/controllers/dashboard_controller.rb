class DashboardController < ApplicationController
  def show
    journeys = Journey.not_remove.includes(:category).where(user_id: current_user.id)
    @journeys = journeys.map { |j| JourneyPresenter.new(j) }
  end

  # :nocov:
  def dsi
    require "dsi/client"
    dsi_client = ::Dsi::Client.new
    # Your details
    @user = current_user
    # make "BuyForYourSchool" DSI admin users visible
    @users = dsi_client.users
    # For developers, use with Postman
    @token = dsi_client.jwt(validity: 3600)
  end
  # :nocov:
end
