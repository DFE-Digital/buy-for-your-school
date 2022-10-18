module FrameworkRequests
  class SelectOrganisationsController < BaseController
    def index
      @form = form || FrameworkSupportForm.new(user: current_user)
    end

  private

    def update_data
      { org_id: @form.org_id, group: @form.group }
    end

    def create_redirect_path
      message_framework_requests_path(framework_support_form: validation.to_h)
    end

    def back_url
      @back_url = framework_requests_path
    end
  end
end
