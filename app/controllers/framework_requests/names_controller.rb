module FrameworkRequests
  class NamesController < BaseController
    skip_before_action :authenticate_user!

  private

    def update_data
      { first_name: @form.first_name, last_name: @form.last_name }
    end

    def create_redirect_path
      email_framework_requests_path(framework_support_form: validation.to_h)
    end

    def back_url
      @back_url = confirm_organisation_framework_requests_path(framework_support_form: validation.to_h)
    end

    def step_description
      I18n.t("faf.name.title")
    end
  end
end
