module FrameworkRequests
  class EnergyAlternativesController < BaseController
    skip_before_action :authenticate_user!

    before_action :edit_back_url, only: %i[update]

    def update
      if @form.valid?
        @form.save!
        if framework_request.reload.different_format_energy_alternative?
          redirect_to edit_framework_request_bill_uploads_path(framework_request)
        else
          redirect_to framework_request_path(framework_request)
        end
      else
        render :edit
      end
    end

  private

    def form
      @form ||= FrameworkRequests::EnergyAlternativeForm.new(all_form_params)
    end

    def form_params
      [:energy_alternative]
    end

    def create_redirect_path
      return bill_uploads_framework_requests_path(framework_support_form: @form.common) if framework_request.different_format_energy_alternative?

      special_requirements_framework_requests_path(framework_support_form: @form.common)
    end

    def back_url
      @back_url = energy_bill_framework_requests_path(framework_support_form: @form.common)
    end

    def edit_back_url
      @back_url = edit_framework_request_energy_bill_path(framework_request)
    end
  end
end
