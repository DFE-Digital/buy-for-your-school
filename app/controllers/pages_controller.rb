class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :redirect_non_page_requests
  before_action :set_breadcrumbs, only: :show

  def show
    # Try Contentful Page first (FABS), then DB-backed Page (BFYS)
    contentful_page = begin
      FABS::Page.find_by_slug!(params[:slug])
    rescue ContentfulRecordNotFoundError
      nil
    end

    if contentful_page
      @page = contentful_page
      @page_title = @page.title
      add_breadcrumb :home_breadcrumb_name, :home_breadcrumb_path
      build_page_breadcrumbs(@page)

      render "fabs_show", layout: "fabs_application"
    else
      # Fall back to DB-backed page
      @page = PagePresenter.new(page)
    end
  end

  # TODO: remove this once pages are dynamic
  def self.bypass_dsi?
    Rails.env.development? && (ENV["DFE_SIGN_IN_ENABLED"] == "false")
  end

private

  def redirect_non_page_requests
    redirect_to "/404" if page.blank? && !contentful_page_exists?
  end

  def contentful_page_exists?
    FABS::Page.find_by_slug!(params[:slug])
    true
  rescue ContentfulRecordNotFoundError
    false
  end

  def page
    @page ||= Page.find_by(slug: params[:slug]) if Page.respond_to?(:find_by)
  end

  # Apply Contentful breadcrumbs in the format "title, path"
  def set_breadcrumbs
    return if contentful_page_exists?

    page&.breadcrumbs&.each { |item| breadcrumb(*item.split(",")) }
  end

  def build_page_breadcrumbs(page)
    node = page.parent
    trail = []
    max_depth = 4

    max_depth.times do
      break unless node

      trail << node

      case node
      when FABS::Category
        @category = node
        break
      when FABS::Page
        node = node.parent
      else
        break
      end
    end

    trail.reverse_each do |n|
      case n
      when FABS::Category
        add_breadcrumb :category_breadcrumb_name, :category_breadcrumb_path
      when FABS::Page
        add_breadcrumb n.title, page_path(n.slug)
      end
    end
  end
end
