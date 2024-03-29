module FrameworkRequests
  class SignInController < BaseController
    skip_before_action :authenticate_user!

  private

    def form
      @form ||= FrameworkRequests::SignInForm.new(all_form_params)
    end

    def create_redirect_path
      organisation_type_framework_requests_path(framework_support_form: @form.common)
    end

    def back_url
      @back_url = url_from(back_link_param) || framework_requests_path
    end
  end
end
