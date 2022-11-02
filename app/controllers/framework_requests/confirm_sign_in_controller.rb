module FrameworkRequests
  class ConfirmSignInController < BaseController
    def index
      @current_user = UserPresenter.new(current_user)
    end

    def create
      framework_request.update!(user: current_user, first_name: current_user.first_name, last_name: current_user.last_name, email: current_user.email)
      redirect_to create_redirect_path
    end

  private

    def create_redirect_path
      @current_user = UserPresenter.new(current_user)
      if @current_user.single_org?
        message_framework_requests_path(framework_support_form: form.data)
      else
        select_organisation_framework_requests_path
      end
    end
  end
end
