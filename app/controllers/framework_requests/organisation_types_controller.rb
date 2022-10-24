module FrameworkRequests
  class OrganisationTypesController < BaseController
    skip_before_action :authenticate_user!

    def update
      if @form.valid?
        redirect_to update_redirect_path
      else
        render :edit
      end
    end

  private

    def form
      @form ||= FrameworkRequests::OrganisationTypeForm.new(all_form_params)
    end

    def create_redirect_path
      search_for_organisation_framework_requests_path(framework_support_form: @form.common)
    end

    def update_redirect_path
      edit_framework_request_search_for_organisation_path(framework_support_form: validation.to_h, group: @form.group)
    end

    def back_url
      @back_url = sign_in_framework_requests_path(framework_support_form: @form.common)
    end

    def step_description
      I18n.t("faf.school_or_group_or_trust.header")
    end
  end
end
