module FrameworkRequests
  class ConfirmOrganisationsController < BaseController
    skip_before_action :authenticate_user!

    def update
      if @form.valid?
        if @form.org_confirm?
          @form.save!
          redirect_to framework_request_path(framework_request), notice: I18n.t("support_request.flash.updated")
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
      %i[organisation_id organisation_type]
    end

    def create_redirect_path
      if @form.org_confirm?
        name_framework_requests_path(framework_support_form: @form.common)
      else
        search_for_organisation_framework_requests_path(framework_support_form: form.common.except(:org_confirm, :organisation_id, :organisation_type))
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
