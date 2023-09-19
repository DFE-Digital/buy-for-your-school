module FrameworkRequests
  class DocumentUploadsController < BaseController
    skip_before_action :authenticate_user!

    before_action :set_document_types, only: %i[index edit]
    before_action :edit_back_url, only: %i[update]

    def list
      files = framework_request.documents.map do |bill|
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
        document = Document.pending.create!(
          file: params[:file],
          framework_request_id: framework_request.id,
          filename: params[:file].original_filename,
        )

        render status: :created, json: { file_id: document.id }
      else
        track_event("Rfh/DocumentUploads/Upload/VirusDetected", framework_request_id: framework_request.id)

        params[:file].tempfile.delete

        render status: :unprocessable_entity, json: { error: "virus detected" }
      end
    end

    def remove
      document = Document.find(params[:file_id])
      document.destroy!
      head :ok
    end

  private

    def file_is_safe?
      Rails.configuration.clamav_scanner.file_is_safe?(params[:file])
    end

    def form
      @form ||= FrameworkRequests::DocumentUploadsForm.new(all_form_params)
    end

    def update_data
      {}
    end

    def create_redirect_path
      special_requirements_framework_requests_path(framework_support_form: form.common)
    end

    def back_url
      @back_url = documents_framework_requests_path(framework_support_form: form.common)
    end

    def edit_back_url
      @back_url =
        if @form.source.change_link?
          framework_request_path
        else
          edit_framework_request_documents_path(framework_request)
        end
    end

    def set_document_types
      @document_types = framework_request.document_types
      @other = framework_request.document_type_other
    end
  end
end
