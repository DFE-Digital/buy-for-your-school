module FrameworkRequests
  class CategoryForm < BaseForm
    validates :category_slug, presence: true
    validates :category_other, presence: true, if: :other_category?

    attr_accessor :category_slug, :category_other, :category_path
    attr_reader :enable_divider, :category, :current_category

    def initialize(attributes = {})
      super
      resolve_category
      resolve_current_category
      @category_other ||= framework_request.category_other
      @enable_divider = @category_path.blank?
    end

    def category_options
      return if multiple_categories?

      categories = @category_path.blank? ? RequestForHelpCategory.top_level.active : @current_category&.sub_categories&.active

      categories.map do |category|
        OpenStruct.new(
          slug: category.slug,
          title: category.title,
          description: category.description,
          enable_conditional_content: category.title == "Other",
        )
      end
    end

    def category_divider_options
      [OpenStruct.new(slug: "multiple", title: I18n.t("faf.categories.multiple.title"))]
    end

    def data
      super.merge(category: @category, category_other: @category&.other? ? @category_other.presence : nil).except(
        :category_slug,
        :category_path,
        :enable_divider,
        :current_category,
      )
    end

    def new_path?
      return true if framework_request.category.nil?

      if @category_slug.present?
        !framework_request.category.hierarchy.map(&:slug).include? @category_slug
      else
        false
      end
    end

    def set_selected_slug
      return if @category_slug == "multiple"

      # get the next category slug in the hierarchy to pre-select the right radio button when
      # we've already selected a category and are navigating back and forth
      next_in_line_slug = @current_category&.find_next_in_hierarchy_to(@category)&.slug
      # get the root parent slug to pre-select if the current category is unavailable
      # (so we're on the base categories page)
      root_parent_slug = @category&.root_parent&.slug

      @category_slug = next_in_line_slug || root_parent_slug
    end

    def parent_category_path = @current_category&.ancestors_slug

    def title = @category_path.blank? ? nil : @current_category&.title&.humanize(capitalize: false)

    def final_category? = @category_slug != "multiple" && RequestForHelpCategory.active.find_by_path(current_path).sub_categories.blank?

    def multiple_categories? = @category_path == "multiple"

    def slugs = { category_path: current_path }

    def current_path = [@category_path, @category_slug].compact.join("/")

    def other_category? = @category_slug == "other"

  private

    def resolve_current_category
      return if @category_path.nil?

      @current_category = RequestForHelpCategory.active.find_by_path(@category_path)
    end

    def resolve_category
      @category =
        if new_path?
          RequestForHelpCategory.active.find_by_path([@category_path, @category_slug].compact.join("/"))
        else
          framework_request.category
        end
    end
  end
end
