module MyProcurements
  class DownloadHandoverPacksController < ApplicationController
    before_action :set_current_case
    before_action :school_buying_professional
    before_action :set_handover_packs
    before_action :set_downloaded_handover_packs
    before_action :set_download_handover_pack, only: %i[update]
    before_action { @back_url = my_procurements_task_path(@current_case) }
    SUPPORTED_TYPES = [
      "Support::UploadContractHandover",
    ].freeze
    def show; end

    def update
      if params[:confirm]
        @school_buying_professional.update!(case_handover_packs_download_params)
        log_all_handover_packs_downloaded
        redirect_to @back_url
      else
        update_support_details
        send_data @download_document.file.download, type: @download_document.file_type, disposition: "attachment", filename: @download_document.file_name
      end
    end

  private

    helper_method def school_buying_professional
      return @school_buying_professional if defined? @school_buying_professional

      @school_buying_professional = Support::ContractRecipient.where("support_case_id = ? AND LOWER(email) = LOWER(?)", params[:id], current_user.email).first
    end
    def set_current_case
      @current_case = Support::Case.find(params[:id])
    end

    def set_downloaded_handover_packs
      @downloaded_documents = Support::DownloadContractHandover.where(support_case_id: @current_case.id, email: current_user.email)
    end

    def check_user_is_evaluator
      return if school_buying_professional.present? && current_user.email.downcase == school_buying_professional.email.downcase

      redirect_to root_path, notice: I18n.t("my_procurements.tasks.not_permitted")
    end

    def set_handover_packs
      @documents = @current_case.upload_contract_handovers
    end

    def case_handover_packs_download_params
      params.require(:handover_packs).permit(:has_downloaded_documents)
    end

    def update_support_details
      unless downloaded_details_exist?
        log_handover_packs_downloaded(@download_document.file_name)
      end

      Support::DownloadContractHandover.upsert(
        {
          support_upload_contract_handover_id: params[:document_id],
          support_case_id: @download_document.support_case_id,
          email: current_user.email,
          has_downloaded_documents: true,
        },
        unique_by: %i[email support_case_id support_upload_contract_handover_id],
      )
    end

    def set_download_handover_pack
      return if params[:confirm]

      @requested_file_type = CGI.unescape(params[:document_type])
      if SUPPORTED_TYPES.include?(@requested_file_type)
        @download_document = @requested_file_type.safe_constantize.find(params[:document_id])
      else
        head :unsupported_media_type
      end
    end

    def downloaded_details_exist?
      Support::DownloadContractHandover.find_by(
        support_upload_contract_handover_id: params[:document_id],
        support_case_id: @download_document.support_case_id,
        email: current_user.email,
      )
    end

    def log_handover_packs_downloaded(file_name)
      data = {
        support_case_id: @current_case.id,
        file_name:,
        document_id: params[:document_id],
        user_id: school_buying_professional.id,
        name: "school buyer #{school_buying_professional.name}",
      }
      Support::EvaluationJourneyTracking.new(:handover_packs_downloaded, data).call
    end

    def log_all_handover_packs_downloaded
      return unless @school_buying_professional.saved_change_to_has_downloaded_documents? && @school_buying_professional.has_downloaded_documents?

      data = {
        support_case_id: @current_case.id,
        user_id: school_buying_professional.id,
        name: "school buyer #{school_buying_professional.name}",
      }
      Support::EvaluationJourneyTracking.new(:all_handover_packs_downloaded, data).call
    end
  end
end
