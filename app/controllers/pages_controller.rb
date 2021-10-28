class PagesController < ApplicationController
  include HighVoltage::StaticPage
  before_action :show_route, :show_method, only: %i[show]

  skip_before_action :authenticate_user!

  # TODO: remove this once pages are dynamic
  def self.bypass_dsi?
    Rails.env.development? && (ENV["DFE_SIGN_IN_ENABLED"] == "false")
  end

  def accessibility
    @body = DocumentFormatter.new(
      content: File.read("./accessibility.md"),
      from: :markdown,
      to: :html,
    ).call

    @time_stamp = Date.new(2021, 7, 7).strftime('%d %b %Y')
  end

  def planning_start_page
    @back_url = root_path
  end

  def show_route
    @start_now_button_route = current_user.guest? ? "/auth/dfe" : dashboard_path
  end

  def show_method
    @start_now_button_method = current_user.guest? ? :post : :get
  end
end
