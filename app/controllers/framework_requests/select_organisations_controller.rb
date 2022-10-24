module FrameworkRequests
  class SelectOrganisationsController < BaseController
    def index
      @form = form || FrameworkSupportForm.new(id: session[:framework_request_id], user: current_user)
    end

  private

    def create_redirect_path
      message_framework_requests_path(framework_support_form: form.common)
    end

    def back_url
      @back_url = framework_requests_path
    end

    def step_description
      I18n.t("faf.user_organisation.header")
    end
  end
end
