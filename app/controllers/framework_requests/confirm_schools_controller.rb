module FrameworkRequests
  class ConfirmSchoolsController < BaseController
    skip_before_action :authenticate_user!

    before_action :schools

    def create
      if @form.valid?
        if @form.school_urns_confirmed?
          @form.save!
          redirect_to create_redirect_path
        else
          redirect_to school_picker_framework_requests_path(framework_support_form: @form.common_with_school_urns)
        end
      else
        render :index
      end
    end

    def update
      if @form.valid?
        if @form.school_urns_confirmed?
          @form.save!
          update_redirect_path
        else
          redirect_to edit_framework_request_school_picker_path(framework_request)
        end
      else
        render :edit
      end
    end

  private

    def schools
      @schools ||= @form.selected_schools
    end

    def form
      @form ||= FrameworkRequests::ConfirmSchoolsForm.new(all_form_params)
    end

    def form_params
      [:school_urns_confirmed, { school_urns: [] }]
    end

    def create_redirect_path
      if current_user.guest?
        name_framework_requests_path(framework_support_form: @form.common)
      else
        categories_framework_requests_path(framework_support_form: @form.common)
      end
    end

    def update_redirect_path
      if flow.unfinished?
        redirect_to edit_framework_request_same_supplier_path(framework_request)
      else
        redirect_to framework_request_path(framework_request), notice: I18n.t("support_request.flash.updated")
      end
    end

    def back_url
      @back_url = school_picker_framework_requests_path(framework_support_form: form.common_with_school_urns)
    end

    def edit_back_url
      @back_url = edit_framework_request_school_picker_path(framework_support_form: form.common_with_school_urns)
    end
  end
end
