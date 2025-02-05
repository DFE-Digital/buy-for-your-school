module Evaluation
  class UploadCompletedDocumentsController < ApplicationController
    before_action :set_current_case
    before_action :check_user_is_evaluator
    before_action { @back_url = evaluation_task_path(@current_case) }
    before_action :uploaded_files
    def show
      @document_uploader = @current_case.document_uploader
    end

    def create
      @document_uploader = @current_case.document_uploader(document_uploader_params)
      if @document_uploader.valid?
        @document_uploader.save_evaluation_document!(current_user.email)
        current_evaluator.update!(case_document_uploader_params)
        redirect_to @back_url
      else
        render :show
      end
    end

    def destroy
      @uploaded_document = Support::EvaluatorsUploadDocument.find(params[:document_id])
      @support_document = Support::Document.find(@uploaded_document.attachable_id)
      @back_url = evaluation_upload_completed_document_path(@current_case)
      return unless params[:confirm]

      @uploaded_document.destroy!
      @support_document.destroy!
      if @uploaded_files.empty?
        reset_uploaded_documents
      end
      redirect_to evaluation_upload_completed_document_path(case_id: @current_case.id),
                  notice: I18n.t("support.cases.upload_documents.flash.destroyed", name: @uploaded_document.file_name)
    end

  private

    helper_method def current_evaluator
      return @current_evaluator if defined? @current_evaluator

      @current_evaluator = Support::Evaluator.where("support_case_id = ? AND LOWER(email) = LOWER(?)", params[:case_id], current_user.email).first
    end
    def set_current_case
      @current_case = Support::Case.find(params[:case_id])
      @evaluation_due_date = @current_case.evaluation_due_date? ? @current_case.evaluation_due_date.strftime("%d %B %Y") : nil
    end

    def document_uploader_params
      params.fetch(:document_uploader, {}).permit(:edit_form, files: [])
    end

    def case_document_uploader_params
      params.require(:document_uploader).permit(:has_uploaded_documents)
    end

    def check_user_is_evaluator
      return if current_evaluator.present? && current_user.email.downcase == current_evaluator.email.downcase

      redirect_to root_path, notice: I18n.t("evaluation.tasks.not_permitted")
    end

    def reset_uploaded_documents
      current_evaluator.update!(has_uploaded_documents: false)
    end

    def uploaded_files
      @uploaded_files ||= Support::EvaluatorsUploadDocument.where(support_case_id: params[:case_id], email: current_user.email)
    end
  end
end
