module FrameworkRequests
  class MessagesController < BaseController
    skip_before_action :authenticate_user!

  private

    def update_data
      { message_body: @form.message_body }
    end

    def create_redirect_path
      procurement_amount_framework_requests_path(framework_support_form: validation.to_h)
    end

    def back_url
      @back_url = determine_back_path
    end

    def determine_back_path
      @current_user = UserPresenter.new(current_user)
      if @form.dsi
        if @current_user.single_org?
          framework_requests_path
        else
          select_organisation_framework_requests_path(framework_support_form: validation.to_h)
        end
      else
        email_framework_requests_path(framework_support_form: validation.to_h)
      end
    end
  end
end