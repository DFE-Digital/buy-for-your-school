module Support
  class DocumentDownloadsController < Cases::ApplicationController
    before_action :set_document

    SUPPORTED_TYPES = [
      "Support::EmailAttachment",
      "Support::CaseAttachment",
      "EnergyBill"
    ].freeze

    def show
      send_data @document.file.download, type: @document.file_type, disposition: "inline", filename: @document.file_name
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
  end
end
