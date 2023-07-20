module FrameworkRequests
  class BillUploadsController < BaseController
    skip_before_action :authenticate_user!

    def list
      files = framework_request.energy_bills.map do |bill|
        {
          file_id: bill.id,
          name: bill.filename,
          size: bill.file.attachment.byte_size,
          type: bill.file.attachment.content_type,
        }
      end
      render status: :ok, json: files.to_json
    end

    def upload
      if file_is_safe?
        energy_bill = EnergyBill.pending.create!(
          file: params[:file],
          framework_request_id: framework_request.id,
          filename: params[:file].original_filename,
        )

        render status: :created, json: { file_id: energy_bill.id }
      else
        track_event("Rfh/BillUploads/Upload/VirusDetected", framework_request_id: framework_request.id)

        params[:file].tempfile.delete

        render status: :unprocessable_entity, json: { error: "virus detected" }
      end
    end

    def remove
      energy_bill = EnergyBill.find(params[:file_id])
      energy_bill.destroy!
      head :ok
    end

  private

    def file_is_safe?
      Rails.configuration.clamav_scanner.file_is_safe?(params[:file])
    end

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
      @back_url = determine_back_path
    end

    def determine_back_path
      @current_user = UserPresenter.new(current_user)
      return email_framework_requests_path(framework_support_form: form.common) if @current_user.guest?
      return last_energy_path if @current_user.single_org?

      select_organisation_framework_requests_path(framework_support_form: form.common)
    end
  end
end
