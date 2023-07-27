# frozen_string_literal: true

class Specify::HomeController < Specify::ApplicationController
  skip_before_action :authenticate_user!

  def show
    @start_now_button_route = current_user.guest? ? "/auth/dfe" : dashboard_path
    @start_now_button_method = current_user.guest? ? :post : :get
  end
end
