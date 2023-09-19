module FrameworkRequests
  class EmailsController < BaseController
    skip_before_action :authenticate_user!

  private

    def form
      @form ||= FrameworkRequests::EmailForm.new(all_form_params)
    end

    def form_params
      [:email]
    end

    def create_redirect_path
      categories_framework_requests_path(framework_support_form: form.common)
    end

    def back_url
      @back_url = name_framework_requests_path(framework_support_form: form.common)
    end
  end
end
