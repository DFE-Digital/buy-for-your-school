module Support
  class Cases::UploadContractHandoversController < Cases::ApplicationController
    before_action :set_current_case
    before_action { @back_url = support_case_path(@current_case, anchor: "tasklist") }
    before_action { @uploaded_handover_packs = current_case.upload_contract_handovers }
    def edit
      @document_uploader = current_case.document_uploader
      @uploaded_handover_packs = current_case.upload_contract_handovers
    end

    def create
      @document_uploader = current_case.document_uploader(upload_contract_handover_params)
      if @document_uploader.valid?
        @document_uploader.save_contract_handover_pack!
        @current_case.update!(case_contract_handover_params)
        log_all_handover_packs_uploaded
        redirect_to @back_url
      else
        render :edit
      end
    end

    def destroy
      @uploaded_document = Support::UploadContractHandover.find(params[:document_id])

      @back_url = edit_support_case_upload_contract_handover_path
      return unless params[:confirm]

      Support::Document.destroy_by(id: @uploaded_document.attachable_id)
      Support::DownloadContractHandover.destroy_by(support_upload_contract_handover_id: params[:document_id])
      @uploaded_document.destroy!

      if @uploaded_handover_packs.empty?
        reset_uploaded_contract_handover
      end

      log_documents_deleted(@uploaded_document.file_name)

      redirect_to edit_support_case_upload_contract_handover_path,
                  notice: I18n.t("support.cases.upload_documents.flash.destroyed", name: @uploaded_document.file_name)
    end

  private

    def set_current_case
      @current_case = Support::Case.find(params[:case_id])
    end

    def upload_contract_handover_params
      params.fetch(:document_uploader, {}).permit(:edit_form, files: [])
    end

    def case_contract_handover_params
      params.require(:document_uploader).permit(:has_uploaded_contract_handovers)
    end

    def reset_uploaded_contract_handover
      @current_case.update!(has_uploaded_contract_handovers: false)
    end

    def log_documents_deleted(file_name)
      data = {
        file_name:,
        document_id: params[:document_id],
        support_case_id: @current_case.id,
        name: "#{Current.agent.first_name} #{Current.agent.last_name}",
        user_id: Current.agent.id,
      }
      Support::EvaluationJourneyTracking.new(:handover_packs_deleted, data).call
    end

    def log_all_handover_packs_uploaded
      return unless @current_case.has_uploaded_contract_handovers?

      data = { support_case_id: @current_case.id, name: "#{Current.agent.first_name} #{Current.agent.last_name}", user_id: Current.agent.id }
      Support::EvaluationJourneyTracking.new(:all_handover_packs_uploaded, data).call
    end
  end
end
