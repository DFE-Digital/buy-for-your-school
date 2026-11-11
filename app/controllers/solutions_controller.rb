class SolutionsController < Fabs::ApplicationController
  include Redirectable

  before_action :redirect_legacy_slugs, only: :show

  def show
    @solution = Solution.find_by_slug!(params[:slug])
    @category = FABS::Category.find_by_slug!(params[:category_slug])
    @primary_category = @solution.primary_category
    @get_expert_help = GetExpertHelp.content

    @page_section_title = t(".section_title")
    @page_title = @solution.title
    @page_description = @solution.description
    @page_header_class = "details-header"
    @seo_description = @solution.seo_description
    add_breadcrumb_on_rails :home_breadcrumb_name, :home_breadcrumb_path
    @canonical_url = category_solution_url(@primary_category.slug, @solution.slug)

    if params[:category_slug].present? && @category.present?
      add_breadcrumb_on_rails :category_breadcrumb_name, :category_breadcrumb_path
    elsif @primary_category
      add_breadcrumb_on_rails :primary_category_breadcrumb_name, :primary_category_breadcrumb_path
    end

    render layout: "fabs_application"
  end
end
