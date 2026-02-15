class SolutionsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :enable_search_in_header

  def index
    @solutions = Solution.all
    @sorted_categories = @solutions.each_with_object({}) { |solution, hash|
      solution.categories.each do |category|
        hash[category.title] ||= { slug: category.title, description: category.description, solutions: [], cat_slug: category.slug }
        hash[category.title][:solutions] << solution
      end
    }.sort_by { |category_slug, _category_data| category_slug }.to_h
    @page_section_title = t(".all_buying_options_section_title")
    @page_title = t(".all_buying_options_title")
    @page_description = t(".all_buying_options_description")
    @page_back_link = request.referer

    add_breadcrumb :home_breadcrumb_name, :home_breadcrumb_path
    render layout: "all_buying_options"
  end

  def show
    @solution = Solution.find_by_slug!(params[:slug])
    @category = FABS::Category.find_by_slug!(params[:category_slug])
    @primary_category = @solution.primary_category

    @page_section_title = t(".section_title")
    @page_title = @solution.title
    @page_description = @solution.description
    @page_header_class = "details-header"
    add_breadcrumb :home_breadcrumb_name, :home_breadcrumb_path
    @canonical_url = category_solution_url(@primary_category.slug, @solution.slug)

    if params[:category_slug].present? && @category.present?
      add_breadcrumb :category_breadcrumb_name, :category_breadcrumb_path
    elsif @primary_category
      add_breadcrumb :primary_category_breadcrumb_name, :primary_category_breadcrumb_path
    end

    render layout: "fabs_application"
  end
end
