module FrameworkRequests
  class BillUploadsController < BaseController
    skip_before_action :authenticate_user!

    def upload
      energy_bill = EnergyBill.pending.create!(
        file: params[:file],
        framework_request_id: framework_request.id,
        filename: params[:file].original_filename,
      )
      render status: :created, json: { energy_bill_id: energy_bill.id }
    end

    def remove
      energy_bill = EnergyBill.find(params[:id])
      energy_bill.destroy!
      head :ok
    end

  private

    def form
      @form ||= FrameworkRequests::BillUploadsForm.new(all_form_params)
    end

    def update_data
      {}
    end

    def create_redirect_path
      message_framework_requests_path(framework_support_form: form.common)
    end

    def back_url
      @back_url = email_framework_requests_path(framework_support_form: form.common)
    end
  end
end
