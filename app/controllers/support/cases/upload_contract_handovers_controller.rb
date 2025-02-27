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
        redirect_to @back_url
      else
        render :edit
      end
    end

    def destroy
      @uploaded_document = Support::UploadContractHandover.find(params[:document_id])
      @support_document = Support::Document.find(@uploaded_document.attachable_id)

      @back_url = edit_support_case_upload_contract_handover_path
      return unless params[:confirm]

      @uploaded_document.destroy!
      @support_document.destroy!

      if @uploaded_handover_packs.empty?
        reset_uploaded_contract_handover
      end
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
  end
end
