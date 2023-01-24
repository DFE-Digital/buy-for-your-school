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
      @current_user = UserPresenter.new(current_user)
      return bill_uploads_framework_requests_path(framework_support_form: form.common) if form.allow_bill_upload?
      return email_framework_requests_path(framework_support_form: form.common) if @current_user.guest?
      return last_energy_path if @current_user.single_org?

      select_organisation_framework_requests_path(framework_support_form: form.common)
    end
  end
end
