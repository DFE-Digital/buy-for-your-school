module FrameworkRequests
  class MessagesController < BaseController
    skip_before_action :authenticate_user!

  private

    def form
      @form ||= FrameworkRequests::MessageForm.new(all_form_params)
    end

    def form_params
      [:message_body]
    end

    def create_redirect_path
      if framework_request.energy_category?
        energy_bill_framework_requests_path(framework_support_form: form.common)
      elsif flow.goods? || flow.not_fully_supported?
        special_requirements_framework_requests_path(framework_support_form: form.common)
      else
        documents_framework_requests_path(framework_support_form: form.common)
      end
    end

    def back_url
      @back_url = procurement_amount_framework_requests_path(framework_support_form: form.common)
    end
  end
end
