class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    render "errors/not_found" if page.blank?
  end

  def specifying_start_page
    @start_now_button_route = current_user.guest? ? "/auth/dfe" : dashboard_path
    @start_now_button_method = current_user.guest? ? :post : :get
  end

  # TODO: remove this once pages are dynamic
  def self.bypass_dsi?
    Rails.env.development? && (ENV["DFE_SIGN_IN_ENABLED"] == "false")
  end

private

  def page
    return @page if @page

    @page = Page.find_by(slug: params[:slug])
    @page = PagePresenter.new(@page)
  end
end
