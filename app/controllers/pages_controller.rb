class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  include Breadcrumbs

  def show
    if page.present?
      set_breadcrumbs
      @page = PagePresenter.new(page)
      render "pages/show", layout: "application"
    elsif fabs_page.present?
      @page = fabs_page

      @page_title = @page.title
      add_breadcrumb(home_breadcrumb_name, home_breadcrumb_path)
      build_page_breadcrumbs(@page)
      render "fabs/pages/show", layout: "pages"
    else
      redirect_to "/404"
    end
  rescue ContentfulRecordNotFoundError
    redirect_to "/404"
  end

  # TODO: remove this once pages are dynamic
  def self.bypass_dsi?
    Rails.env.development? && (ENV["DFE_SIGN_IN_ENABLED"] == "false")
  end

private

  def page
    @page ||= Page.find_by(slug: params[:slug])
  end

  def fabs_page
    @page = FABS::Page.find_by_slug!(params[:slug])
  end

  # Apply Contentful breadcrumbs in the format "title, path"
  def set_breadcrumbs
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
        add_breadcrumb category_breadcrumb_name, category_breadcrumb_path
      when FABS::Page
        add_breadcrumb n.title, page_path(n.slug)
      end
    end
  end
end
