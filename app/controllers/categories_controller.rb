class CategoriesController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :enable_search_in_header, except: :index

  def index
    @categories = FABS::Category.all
    @featured_offers = Offer.featured_offers.select { |offer| offer.sort_order.present? }.first(3)
    @energy_banner = Banner.find_by_slug(ENV.fetch("HOMEPAGE_BANNER_SLUG", "homepage-banner"))
    render layout: "homepage"
  end

  def show
    add_breadcrumb :home_breadcrumb_name, :root_path

    @category = FABS::Category.find_by_slug!(params[:slug])
    @subcategories = @category.subcategories
    @selected_subcategories = @subcategories.select { |subcategory| params[:subcategory_slugs]&.include?(subcategory.slug) }
    @solutions = @category.filtered_solutions(subcategory_slugs: params[:subcategory_slugs]&.compact_blank)
    @dfe_solutions, @other_solutions = @solutions.partition(&:buying_option_type)
    @page_section_title = t(".section_title")
    @page_header_class = "category-header"
    @page_title = @category.title
    @page_description = @category.description
    @category_slug = @category.slug
    
    render layout: "all_buying_options"
  end
end
