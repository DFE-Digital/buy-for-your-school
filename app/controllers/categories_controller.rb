class CategoriesController < Fabs::ApplicationController
  include Redirectable

  before_action :redirect_legacy_slugs, only: :show

  DUMMY_SUBCATEGORY_SLUG = "not-applicable".freeze

  def index
    @categories = FABS::Category.all
    @featured_offers = Offer.featured_offers.select { |offer| offer.sort_order.present? }.first(2)
    @popular_links = PopularLink.all.select { |popular_link| popular_link.sort_order.present? }.first(6)
    @energy_banner = Banner.find_by_slug(ENV.fetch("HOMEPAGE_BANNER_SLUG", "homepage-banner"))

    render layout: "homepage"
  end

  def show
    add_breadcrumb_on_rails :home_breadcrumb_name, :root_path

    @subcategories = category.subcategories.reject { _1.slug.downcase == DUMMY_SUBCATEGORY_SLUG }
    @selected_subcategories = @subcategories.select { |subcategory| params[:subcategory_slugs]&.include?(subcategory.slug) }
    @solutions = @category.filtered_solutions(subcategory_slugs: params[:subcategory_slugs]&.compact_blank, ways_to_buy_slugs: params[:ways_to_buy_slugs]&.compact_blank)

    @solutions_count_subcategory = solutions_count_by_subcategory(@solutions)
    @solutions_count_ways_to_buy = solutions_count_by_ways_to_buy(@solutions)
    @ways_to_buy = ways_to_buy
    @get_expert_help = GetExpertHelp.content

    @page_section_title = t(".section_title")
    @page_header_class = "category-header"
    @page_title = @category.title
    @page_description = @category.description

    @body_title = @category.body_title
    @body_description = @category.body_description

    @category_slug = @category.slug

    render layout: "fabs_application"
  end

private

  def solutions_count_by_subcategory(solutions)
    solutions.each_with_object(Hash.new(0)) do |solution, counts|
      solution.subcategories.to_a.each do |subcategory|
        counts[subcategory.slug] += 1
      end
    end
  end

  def solutions_count_by_ways_to_buy(solutions)
    solutions.each_with_object(Hash.new(0)) do |solution, counts|
      counts[solution.ways_to_buy&.slug] += 1
    end
  end

  def category
    @category ||= FABS::Category.find_by_slug!(params[:slug])
  end

  def ways_to_buy
    category.solutions.map(&:ways_to_buy).compact.map { |entry| WaysToBuy.new(entry) }.sort_by(&:title).uniq(&:title)
  end
end
