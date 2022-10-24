module FrameworkRequests
  class OrganisationTypesController < BaseController
    skip_before_action :authenticate_user!

    def update
      if validation.success?
        redirect_to update_redirect_path
      else
        render :edit
      end
    end

  private

    def create_redirect_path
      search_for_organisation_framework_requests_path(framework_support_form: validation.to_h)
    end

    def update_redirect_path
      edit_framework_request_search_for_organisation_path(framework_support_form: validation.to_h, group: @form.group)
    end

    def back_url
      @back_url = sign_in_framework_requests_path(framework_support_form: validation.to_h)
    end
  end
end
