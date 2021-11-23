class PagesController < ApplicationController
  include HighVoltage::StaticPage

  skip_before_action :authenticate_user!

  # TODO: remove this once pages are dynamic
  def self.bypass_dsi?
    Rails.env.development? && (ENV["DFE_SIGN_IN_ENABLED"] == "false")
  end

  def specifying_start_page
    @start_now_button_route = current_user.guest? ? "/auth/dfe" : dashboard_path
    @start_now_button_method = current_user.guest? ? :post : :get
  end

  def show
    @title = page.title
    @body = formatter(page.body)
    @sidebar = formatter(page.sidebar)
    @time_stamp = page.updated_at.strftime("%e %B %Y")
  end

private

  def formatter(content)
    DocumentFormatter.new(
      content: content,
      from: :markdown,
      to: :html,
    ).call
  end

  def page
    @page ||= Page.find_by(slug: params[:id])
  end
end
