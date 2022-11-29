module FrameworkRequests
  class EnergyRequestController < BaseController
    skip_before_action :authenticate_user!

  private

    def form
      @form ||= FrameworkRequests::EnergyRequestForm.new(all_form_params)
    end

    def form_params
      [:is_energy_request]
    end

    def create_redirect_path
      if @form.is_energy_request?
        energy_request_about_framework_requests_path(framework_support_form: @form.common)
      else
        sign_in_framework_requests_path(framework_support_form: @form.common)
      end
    end

    def back_url
      @back_url = framework_requests_path
    end
  end
end
