module FrameworkRequests
  class ConfirmSignInController < BaseController
    before_action :current_user

    def index; end

    def create
      framework_request.set_inferred_attributes!(current_user)
      redirect_to create_redirect_path
    end

  private

    def current_user
      @current_user = UserPresenter.new(super)
    end

    def create_redirect_path
      return select_organisation_framework_requests_path(framework_support_form: form.common) unless @current_user.single_org?
      return school_picker_framework_requests_path(framework_support_form: form.common) if @current_user.belongs_to_trust_or_federation? && @current_user.org.organisations.present?

      categories_framework_requests_path(framework_support_form: form.common)
    end
  end
end
