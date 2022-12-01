module FrameworkRequests
  class EnergyAlternativeController < BaseController
    skip_before_action :authenticate_user!

  private

    def form
      @form ||= FrameworkRequests::EnergyAlternativeForm.new(all_form_params)
    end

    def form_params
      [:energy_alternative]
    end

    def create_redirect_path
      sign_in_framework_requests_path(framework_support_form: @form.common, back_to: current_url_b64)
    end

    def back_url
      @back_url = energy_bill_framework_requests_path(framework_support_form: @form.common)
    end
  end
end
