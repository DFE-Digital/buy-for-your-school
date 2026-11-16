class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  include Breadcrumbs
  include Redirectable
  include Referable

  before_action :redirect_legacy_slugs
  before_action :remember_energy_referrer, if: :energy_page?
  before_action :remember_request_referrer, if: :referable_page?

  def show
    if page.present?
      @page_title = @page.title
      @seo_description = @page.seo_description
      add_breadcrumb_on_rails(home_breadcrumb_name, home_breadcrumb_path)
      build_page_breadcrumbs(@page)
      render "fabs/pages/show", layout: "pages"
    else
      render "errors/not_found", status: :not_found
    end
  rescue ContentfulRecordNotFoundError
    render "errors/not_found", status: :not_found
  end

  # TODO: remove this once pages are dynamic
  def self.bypass_dsi?
    Rails.env.development? && (ENV["DFE_SIGN_IN_ENABLED"] == "false")
  end

private

  def page
    @page ||= FABS::Page.find_by_slug!(params[:slug])
  end

  def referable_page?
    params[:slug].to_s == "procurement-support"
  end

  def energy_page?
    params[:slug].to_s.start_with?("energy/")
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
        add_breadcrumb_on_rails :category_breadcrumb_name, :category_breadcrumb_path
      when FABS::Page
        add_breadcrumb_on_rails n.title, page_path(n.slug)
      end
    end
  end
end
