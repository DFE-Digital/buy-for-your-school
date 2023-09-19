module FrameworkRequests
  class EnergyBillsController < BaseController
    skip_before_action :authenticate_user!

    before_action :edit_back_url, only: %i[update]

    def update
      if @form.valid?
        @form.save!
        if @form.have_energy_bill?
          redirect_to edit_framework_request_bill_uploads_path(framework_request)
        else
          redirect_to edit_framework_request_energy_alternative_path(framework_request)
        end
      else
        render :edit
      end
    end

  private

    def form
      @form ||= FrameworkRequests::EnergyBillForm.new(all_form_params)
    end

    def form_params
      [:have_energy_bill]
    end

    def create_redirect_path
      return bill_uploads_framework_requests_path(framework_support_form: @form.common) if @form.have_energy_bill?

      energy_alternative_framework_requests_path(framework_support_form: @form.common)
    end

    def back_url
      @back_url = message_framework_requests_path(framework_support_form: @form.common)
    end

    def edit_back_url
      @back_url =
        if framework_request.multischool_with_multiple_selections?
          edit_framework_request_same_supplier_path(framework_request)
        else
          edit_framework_request_contract_start_date_path(framework_request)
        end
    end
  end
end
