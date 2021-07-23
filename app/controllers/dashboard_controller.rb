class DashboardController < ApplicationController
  def show
    @current_user = current_user
    @journeys = Journey.not_remove.includes(:category).where(user_id: current_user.id)
  end
end
