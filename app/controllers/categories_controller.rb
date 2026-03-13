class CategoriesController < Fabs::ApplicationController
  before_action :disable_search_in_header, only: :index

  def index
    @categories = FABS::Category.all
    @featured_offers = Offer.featured_offers.select { |offer| offer.sort_order.present? }.first(3)
    @energy_banner = Banner.find_by_slug(ENV.fetch("HOMEPAGE_BANNER_SLUG", "homepage-banner"))
    render layout: "homepage"
  end

private

  def disable_search_in_header
    @show_search_in_header = false
  end
end
