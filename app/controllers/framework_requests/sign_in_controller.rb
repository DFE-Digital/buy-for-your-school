module FrameworkRequests
  class SignInController < BaseController
    skip_before_action :authenticate_user!

    before_action :form, only: %i[create update]

    def index
      session.delete(:faf_group)
      session.delete(:faf_school)

      @form = form || FrameworkSupportForm.new(user: current_user)
    end

  private

    def create_redirect_path
      organisation_type_framework_requests_path(framework_support_form: validation.to_h)
    end

    def back_url
      @back_url = framework_requests_path
    end

    def step_description
      I18n.t("faf.dsi_or_search.header")
    end
  end
end
