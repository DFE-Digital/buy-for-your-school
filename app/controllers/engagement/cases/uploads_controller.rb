# frozen_string_literal: true

module Engagement
  module Cases
    class UploadsController < Engagement::CasesController
      def upload
        if file_is_safe?
          upload = EngagementCaseUpload.pending.create!(
            file: params[:file],
            upload_reference: params[:upload_reference],
            filename: params[:file].original_filename,
            filesize: File.size(params[:file].tempfile.path),
          )
          render status: :ok, json: { file_id: upload.id }.to_json
        else
          Rollbar.error("Infected file uploaded", upload_reference: params[:upload_reference])

          params[:file].tempfile.delete

          render status: :unprocessable_entity, json: { error: "virus detected" }
        end
      end

      def remove
        attachment = EngagementCaseUpload.find(params[:file_id])
        attachment.destroy!
        head :ok
      end

      def list
        reference = params[:upload_reference]
        files = EngagementCaseUpload.where(upload_reference: reference)
        result = files.map do |f|
          {
            file_id: f.id,
            name: f.filename,
            size: f.filesize,
            type: f.file.attachment.content_type,
          }
        end
        render status: :ok, json: (result || []).to_json
      end

    private

      def file_is_safe?
        Rails.configuration.clamav_scanner.file_is_safe?(params[:file])
      end
    end
  end
end
