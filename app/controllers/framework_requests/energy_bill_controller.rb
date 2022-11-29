module FrameworkRequests
  class EnergyBillController < BaseController
    skip_before_action :authenticate_user!

  private

    def form
      @form ||= FrameworkRequests::EnergyBillForm.new(all_form_params)
    end

    def form_params
      [:have_energy_bill]
    end

    def create_redirect_path
      if @form.have_energy_bill?
        sign_in_framework_requests_path(framework_support_form: @form.common)
      else
        energy_alternative_framework_requests_path(framework_support_form: @form.common)
      end
    end

    def back_url
      @back_url = energy_request_about_framework_requests_path(framework_support_form: @form.common)
    end
  end
end
