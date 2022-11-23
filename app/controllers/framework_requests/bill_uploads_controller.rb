module FrameworkRequests
  class BillUploadsController < BaseController
    skip_before_action :authenticate_user!

  private

    def form
      @form ||= FrameworkRequests::BillUploadsForm.new(all_form_params)
    end

    def form_params
      %i[x y z]
    end

    def update_data
      {}
    end

    def create_redirect_path
      message_framework_requests_path(framework_support_form: form.common)
    end

    def back_url
      @back_url = email_framework_requests_path(framework_support_form: form.common)
    end
  end
end
