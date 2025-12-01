class Specify::DashboardController < Specify::ApplicationController
  breadcrumb "Dashboard", :dashboard_path

  def show
    @user = UserPresenter.new(current_user)
    journeys = Journey.not_remove.includes(:category).where(user_id: current_user.id)
    @journeys = journeys.map { |j| JourneyPresenter.new(j) }
  end
end
