module FrameworkRequests
  class CategoriesController < BaseController
    skip_before_action :authenticate_user!

    before_action :page_title, only: %i[index edit create update]

    def index
      render :multiple if @form.multiple_categories?

      @form.set_selected_slug
    end

    def edit
      super
      render :multiple if @form.multiple_categories?

      @form.set_selected_slug
    end

    def create
      return render :index unless @form.valid?

      @form.save! if @form.new_path?

      if @form.final_category?
        redirect_to procurement_amount_framework_requests_path(framework_support_form: @form.common)
      else
        redirect_to categories_framework_requests_path(**@form.slugs, framework_support_form: @form.common)
      end
    end

    def update
      return render :edit unless @form.valid?

      if @form.final_category?
        @form.save!
        redirect_to framework_request_path(framework_request), notice: I18n.t("support_request.flash.updated")
      else
        redirect_to edit_framework_request_category_path(framework_request, **@form.slugs)
      end
    end

  private

    def back_url = @back_url = determine_back_path

    def edit_back_url
      return edit_framework_request_category_path(framework_support_form: @form.common.merge(category_slug: "multiple")) if category_path == "multiple"
      return framework_request_path(@form.framework_request) if category_path.nil?

      edit_framework_request_category_path(category_path: @form.parent_category_path, framework_support_form: @form.common.merge(category_slug: @form.current_category.slug))
    end

    def determine_back_path
      return categories_framework_requests_path(framework_support_form: @form.common.merge(category_slug: "multiple")) if category_path == "multiple"
      return message_framework_requests_path(framework_support_form: @form.common) if category_path.nil?

      categories_framework_requests_path(category_path: @form.parent_category_path, framework_support_form: @form.common)
    end

    def form_params = %i[category_slug category_other]

    def all_form_params = super.merge(category_path:)

    def form = @form ||= FrameworkRequests::CategoryForm.new(all_form_params)

    def category_path = @category_path ||= params.fetch(:category_path, nil)

    def page_title = @page_title ||= @form.title ? I18n.t("faf.categories.category_title", category: @form.title) : I18n.t("faf.categories.title")
  end
end
