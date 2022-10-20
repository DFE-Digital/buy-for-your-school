module FrameworkRequests
  class ProcurementConfidencesController < BaseController
    skip_before_action :authenticate_user!

  private

    def update_data
      { confidence_level: @form.confidence_level }
    end

    def create_redirect_path
      special_requirements_framework_requests_path(framework_support_form: validation.to_h)
    end

    def back_url
      @back_url = procurement_amount_framework_requests_path(framework_support_form: validation.to_h)
    end

    def step_description
      I18n.t("request.confidence_level.heading")
    end
  end
end
