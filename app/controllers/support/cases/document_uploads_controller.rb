module Support
  class Cases::DocumentUploadsController < Cases::ApplicationController
    before_action :set_current_case
    before_action { @back_url = support_case_path(@current_case, anchor: "tasklist") }
    before_action { @uploaded_files = current_case.upload_documents }
    def edit
      @document_uploader = current_case.document_uploader
      @uploaded_files = current_case.upload_documents
    end

    def create
      @document_uploader = current_case.document_uploader(document_uploader_params)
      if @document_uploader.valid?
        @document_uploader.save!
        @current_case.update!(case_document_uploader_params)
        log_all_documents_uploaded
        redirect_to @back_url
      else
        render :edit
      end
    end

    def destroy
      @uploaded_document = Support::CaseUploadDocument.find(params[:document_id])
      @support_document = Support::Document.find(@uploaded_document.attachable_id)
      evaluator_download_document = Support::EvaluatorsDownloadDocument.find_by(support_case_upload_document_id: params[:document_id])
      @back_url = edit_support_case_document_uploads_path
      return unless params[:confirm]

      @uploaded_document.destroy!
      @support_document.destroy!
      if evaluator_download_document
        evaluator_download_document.destroy!
      end

      if @uploaded_files.empty?
        reset_uploaded_documents
      end

      log_documents_deleted(@uploaded_document.file_name)

      redirect_to edit_support_case_document_uploads_path,
                  notice: I18n.t("support.cases.upload_documents.flash.destroyed", name: @uploaded_document.file_name)
    end

  private

    def set_current_case
      @current_case = Support::Case.find(params[:case_id])
    end

    def document_uploader_params
      params.fetch(:document_uploader, {}).permit(:edit_form, files: [])
    end

    def case_document_uploader_params
      params.require(:document_uploader).permit(:has_uploaded_documents)
    end

    def reset_uploaded_documents
      @current_case.update!(has_uploaded_documents: false)
    end

    def log_documents_deleted(file_name)
      data = {
        file_name:,
        document_id: params[:document_id],
        support_case_id: @current_case.id,
        name: "#{Current.agent.first_name} #{Current.agent.last_name}",
        user_id: Current.agent.id,
      }
      Support::EvaluationJourneyTracking.new(:documents_deleted, data).call
    end

    def log_all_documents_uploaded
      return unless @current_case.saved_change_to_has_uploaded_documents?

      data = { support_case_id: @current_case.id, name: "#{Current.agent.first_name} #{Current.agent.last_name}", user_id: Current.agent.id }

      if @current_case.has_uploaded_documents?
        Support::EvaluationJourneyTracking.new(:all_documents_uploaded, data).call
      else
        Support::EvaluationJourneyTracking.new(:documents_uploaded_in_complete, data).call
      end
    end
  end
end
