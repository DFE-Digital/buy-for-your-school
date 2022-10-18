module FrameworkRequests
  class ConfirmSignInController < ApplicationController
    before_action :current_user

    def create
      redirect_to create_redirect_path
    end

  private

    def create_redirect_path
      if @current_user.single_org?
        form = FrameworkSupportForm.new(user: current_user)
        message_framework_requests_path(framework_support_form: form.data)
      else
        select_organisation_framework_requests_path
      end
    end

    def current_user
      @current_user = UserPresenter.new(super)
    end
  end
end
