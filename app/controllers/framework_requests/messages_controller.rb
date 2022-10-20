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
      return email_framework_requests_path(framework_support_form: validation.to_h) unless @form.dsi

      @current_user = UserPresenter.new(current_user)
      if @current_user.single_org?
        framework_requests_path
      else
        select_organisation_framework_requests_path(framework_support_form: validation.to_h)
      end
    end

    def step_description
      I18n.t("faf.user_query.label")
    end
  end
end
