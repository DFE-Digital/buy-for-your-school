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
        update_action_required
        notify_procops_document_uploaded
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
        update_action_required
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

    def procops_notify_enabled?
      Flipper.enabled?(:sc_tasklist_case)
    end

    def update_action_required
      return unless procops_notify_enabled?

      @current_case.update!(action_required: notify_procops_action_required?)
    end

    def notify_procops_action_required?
      unread_emails = Email.where(ticket_id: params[:case_id], folder: 0, is_read: false).any?
      pending_evaluations = Support::Evaluator.where(support_case_id: params[:case_id], has_uploaded_documents: true, evaluation_approved: false).any?
      unread_emails || pending_evaluations
    end

    def agent_present_and_documents_uploaded?
      @current_case.agent.present? && current_evaluator.has_uploaded_documents?
    end

    def notify_procops_document_uploaded
      return unless procops_notify_enabled?

      notify_agent_if_documents_uploaded
    end

    def notify_agent_if_documents_uploaded
      return unless agent_present_and_documents_uploaded?

      email = Email.create!(
        ticket_id: @current_case.id,
        folder: 0,
        is_read: false,
        subject: "procurement evaluation documents submitted",
        body: "Evaluation documents uploaded",
        sender: { name: current_user.first_name, address: current_user.email },
        recipients: { name: @current_case.agent.full_name, address: @current_case.agent.email },
        ticket_type: @current_case.class.name,
      )

      @current_case.notify_agent_of_evaluation_submitted(email)
    end
  end
end
