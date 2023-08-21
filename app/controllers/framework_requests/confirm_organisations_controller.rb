module FrameworkRequests
  class ConfirmOrganisationsController < BaseController
    skip_before_action :authenticate_user!

    def update
      if @form.valid?
        if @form.org_confirm?
          @form.save!
          if @form.eligible_for_school_picker?
            redirect_to edit_framework_request_school_picker_path(framework_request)
          else
            redirect_to framework_request_path(framework_request), notice: I18n.t("support_request.flash.updated")
          end
        else
          redirect_to edit_framework_request_search_for_organisation_path(framework_request, school_type: @form.school_type)
        end
      else
        render :edit
      end
    end

  private

    def form
      @form ||= FrameworkRequests::ConfirmOrganisationForm.new(all_form_params)
    end

    def form_params
      [:org_id]
    end

    def create_redirect_path
      if @form.org_confirm?
        if @form.eligible_for_school_picker?
          school_picker_framework_requests_path(framework_support_form: @form.common)
        else
          name_framework_requests_path(framework_support_form: @form.common)
        end
      else
        search_for_organisation_framework_requests_path(framework_support_form: form.common.except(:org_confirm))
      end
    end

    def back_url
      @back_url = search_for_organisation_framework_requests_path(framework_support_form: form.common)
    end

    def edit_back_url
      @back_url = edit_framework_request_search_for_organisation_path(framework_support_form: @form.common)
    end
  end
end
