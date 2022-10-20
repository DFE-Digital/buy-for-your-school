module FrameworkRequests
  class EmailsController < BaseController
    skip_before_action :authenticate_user!

  private

    def update_data
      { email: @form.email }
    end

    def create_redirect_path
      message_framework_requests_path(framework_support_form: validation.to_h)
    end

    def back_url
      @back_url = name_framework_requests_path(framework_support_form: validation.to_h)
    end

    def step_description
      I18n.t("faf.email.title")
    end
  end
end
