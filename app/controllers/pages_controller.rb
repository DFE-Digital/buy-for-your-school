class PagesController < ApplicationController
  include HighVoltage::StaticPage
  before_action :show_route, :show_method, only: %i[show]

  skip_before_action :authenticate_user!

  # TODO: remove this once pages are dynamic
  def self.bypass_dsi?
    Rails.env.development? && (ENV["DFE_SIGN_IN_ENABLED"] == "false")
  end

  def privacy
    set_page(__method__)
  end
  
  def accessibility
    set_page(__method__)
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

private

  def set_page(slug)
    page = Page.find_by(slug: slug.to_s)

    @body = DocumentFormatter.new(
      content: page.body,
      from: :markdown,
      to: :html,
    ).call

    @title = page.title
  end
end
