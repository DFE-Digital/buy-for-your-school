class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :redirect_non_page_requests
  before_action :set_breadcrumbs, only: :show

  def show
    @page = PagePresenter.new(page)
  end

  # TODO: remove this once pages are dynamic
  def self.bypass_dsi?
    Rails.env.development? && (ENV["DFE_SIGN_IN_ENABLED"] == "false")
  end

private

  def redirect_non_page_requests
    redirect_to "/404" if page.blank?
  end

  def page
    @page ||= Page.find_by(slug: params[:slug])
  end

  # Apply Contentful breadcrumbs in the format "title, path"
  def set_breadcrumbs
    page&.breadcrumbs&.each { |item| breadcrumb(*item.split(",")) }
  end
end
