module Support
  class DocumentDownloadsController < Cases::ApplicationController
    before_action :set_document, only: :show
    before_action :set_download_document, only: :update

    SUPPORTED_TYPES = [
      "Support::EmailAttachment",
      "EmailAttachment",
      "Support::CaseAttachment",
      "EnergyBill",
      "Support::EmailTemplateAttachment",
      "Support::CaseUploadDocument",
      "Support::EvaluatorsUploadDocument",
      "Support::UploadContractHandover",
    ].freeze

    def show
      send_data @document.file.download, type: @document.file_type, disposition: "inline", filename: @document.file_name
    end

    def update
      send_data @download_document.file.download, type: @download_document.file_type, disposition: "attachment", filename: @download_document.file_name
    end

  private

    def set_document
      requested_file_type = params[:type]

      if SUPPORTED_TYPES.include?(requested_file_type)
        @document = requested_file_type.safe_constantize.find(params[:id])
      else
        head :unsupported_media_type
      end
    end

    def set_download_document
      @requested_file_type = CGI.unescape(params[:document_type])
      if SUPPORTED_TYPES.include?(@requested_file_type)
        @download_document = @requested_file_type.safe_constantize.find(params[:document_id])
      else
        head :unsupported_media_type
      end
    end
  end
end
