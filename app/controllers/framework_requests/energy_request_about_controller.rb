module FrameworkRequests
  class EnergyRequestAboutController < BaseController
    skip_before_action :authenticate_user!

  private

    def form
      @form ||= FrameworkRequests::EnergyRequestAboutForm.new(all_form_params)
    end

    def form_params
      [:energy_request_about]
    end

    def create_redirect_path
      case @form.energy_request_about
      when :energy_contract then energy_bill_framework_requests_path(framework_support_form: @form.common)
      else sign_in_framework_requests_path(framework_support_form: @form.common, back_to: current_url_b64)
      end
    end

    def back_url
      @back_url = energy_request_framework_requests_path(framework_support_form: @form.common)
    end
  end
end
