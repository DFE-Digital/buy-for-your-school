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

      redirect_to create_redirect_path
    end

    def update
      return render :edit unless @form.valid?

      if @form.final_category?
        @form.save!
        if flow.unfinished?
          redirect_to edit_framework_request_contract_length_path(framework_request)
        else
          redirect_to framework_request_path(framework_request), notice: I18n.t("support_request.flash.updated")
        end
      else
        redirect_to edit_framework_request_category_path(framework_request, **@form.slugs)
      end
    end

  private

    def back_url = @back_url = determine_back_path

    def create_redirect_path
      if @form.final_category?
        if flow.energy_or_services?
          contract_length_framework_requests_path(framework_support_form: @form.common)
        else
          procurement_amount_framework_requests_path(framework_support_form: @form.common)
        end
      else
        categories_framework_requests_path(**@form.slugs, framework_support_form: @form.common)
      end
    end

    def edit_back_url
      return edit_framework_request_category_path(framework_support_form: @form.common.merge(category_slug: "multiple")) if category_path == "multiple"
      return framework_request_path(@form.framework_request) if category_path.nil?

      edit_framework_request_category_path(category_path: @form.parent_category_path, framework_support_form: @form.common.merge(category_slug: @form.current_category.slug))
    end

    def determine_back_path
      @current_user = UserPresenter.new(current_user)

      if category_path == "multiple"
        categories_framework_requests_path(framework_support_form: @form.common.merge(category_slug: "multiple"))
      elsif category_path.nil?
        if @current_user.guest?
          email_framework_requests_path(framework_support_form: @form.common)
        elsif form.eligible_for_school_picker?
          confirm_schools_framework_requests_path(framework_support_form: @form.common)
        elsif @current_user.single_org?
          confirm_sign_in_framework_requests_path(framework_support_form: @form.common)
        else
          select_organisation_framework_requests_path(framework_support_form: @form.common)
        end
      else
        categories_framework_requests_path(category_path: @form.parent_category_path, framework_support_form: @form.common)
      end
    end

    def form_params = %i[category_slug category_other]

    def all_form_params = super.merge(category_path:)

    def form = @form ||= FrameworkRequests::CategoryForm.new(all_form_params)

    def category_path = @category_path ||= params.fetch(:category_path, nil)

    def page_title = @page_title ||= @form.title ? I18n.t("faf.categories.category_title", category: @form.title) : I18n.t("faf.categories.title")
  end
end
