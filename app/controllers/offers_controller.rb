class OffersController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :enable_search_in_header

  def index
    @offers = Offer.all

    @page_section_title = t(".section_title")
    @page_title = t(".title")
    @page_description = t(".description")
    @page_header_class = "category-header"
    @page_back_link = request.referer

    add_breadcrumb :home_breadcrumb_name, :home_breadcrumb_path
    render layout: "all_offers"
  end

  def show
    @offer = Offer.find_by_slug!(params[:slug])

    @page_section_title = t(".section_title")
    @page_title = @offer.title
    @page_description = @offer.description
    @page_header_class = "details-header"
    add_breadcrumb :home_breadcrumb_name, :home_breadcrumb_path

    add_breadcrumb :offers_breadcrumb_name, :offers_breadcrumb_path
  end
end
