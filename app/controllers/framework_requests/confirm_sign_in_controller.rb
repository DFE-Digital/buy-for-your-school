module FrameworkRequests
  class ConfirmSignInController < BaseController
    before_action :form, only: %i[create]

    def index
      @current_user = UserPresenter.new(current_user)
    end

  private

    def create_redirect_path
      @current_user = UserPresenter.new(current_user)
      return select_organisation_framework_requests_path(framework_support_form: form.common) unless @current_user.single_org?
      return bill_uploads_framework_requests_path(framework_support_form: form.common) if @form.allow_bill_upload?

      message_framework_requests_path(framework_support_form: form.common)
    end

    def form
      @form ||= FrameworkRequests::ConfirmSignInForm.new(all_form_params)
    end
  end
end
