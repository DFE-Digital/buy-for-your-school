class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  include Breadcrumbs
  include Redirectable

  before_action :redirect_legacy_slugs
  before_action :remember_energy_onboarding, if: :energy_page?

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

  def energy_page?
    params[:slug].to_s.start_with?("energy/")
  end

  # Flags the session so SessionsController#entry_path sends the user
  # into the energy journey after DfE Sign-in
  def remember_energy_onboarding
    session.delete(:email_evaluator_link)
    session.delete(:email_school_buyer_link)
    session.delete(:faf_referrer)
    session[:energy_onboarding] = true
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
