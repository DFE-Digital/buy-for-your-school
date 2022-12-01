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
      return procurement_amount_framework_requests_path(framework_support_form: form.common) unless form.allow_bill_upload?

      procurement_confidence_framework_requests_path(framework_support_form: form.common)
    end

    def back_url
      @back_url = determine_back_path
    end

    def determine_back_path
      return email_framework_requests_path(framework_support_form: form.common) if form.user.guest?

      @current_user = UserPresenter.new(current_user)
      if @current_user.single_org?
        framework_requests_path
      else
        select_organisation_framework_requests_path(framework_support_form: form.common)
      end
    end
  end
end
