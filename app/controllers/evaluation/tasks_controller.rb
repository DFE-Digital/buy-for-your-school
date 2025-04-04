module Evaluation
  class TasksController < ApplicationController
    before_action :authenticate_user!, only: %i[edit]
    before_action :set_current_case
    before_action :check_user_is_evaluator
    before_action :set_uploaded_documents
    before_action :set_downloaded_documents
    before_action :uploaded_evaluation_files
    before_action :upload_document_status

    def edit
      session[:email_evaluator_link] = evaluation_task_path(@current_case, host: request.host)
      redirect_to evaluation_task_path(@current_case)
    end

    def show; end

  private

    helper_method def current_evaluator
      return @current_evaluator if defined? @current_evaluator

      @current_evaluator = Support::Evaluator.where("support_case_id = ? AND LOWER(email) = LOWER(?)", params[:id], current_user.email).first
    end

    def set_current_case
      @current_case = Support::Case.find(params[:id])
      @evaluation_due_date = @current_case.evaluation_due_date? ? @current_case.evaluation_due_date.strftime("%d %B %Y") : nil
    end

    def check_user_is_evaluator
      return if current_evaluator.present? && current_user.email.downcase == current_evaluator.email.downcase

      redirect_to evaluation_signin_path, notice: I18n.t("evaluation.tasks.not_permitted")
    end

    def set_downloaded_documents
      @downloaded_documents = Support::EvaluatorsDownloadDocument.where(support_case_id: params[:id], email: current_user.email)
    end

    def set_uploaded_documents
      @documents = @current_case.upload_documents
    end

    def upload_document_status
      partial_uploaded = current_evaluator && !current_evaluator.has_uploaded_documents && @uploaded_evaluation_files.any?
      @upload_document_status = if current_evaluator&.has_downloaded_documents? && current_evaluator&.has_uploaded_documents?
                                  :complete
                                elsif current_evaluator&.has_downloaded_documents? && partial_uploaded
                                  :in_progress
                                else
                                  :to_do
                                end
    end

    def authenticate_user!
      return unless current_user.guest?

      session.delete(:dfe_sign_in_uid)
      session[:email_evaluator_link] = evaluation_task_path(id: params[:id], host: request.host)
      session[:evaluator_signin_link] = evaluation_signin_path(id: params[:id])
      redirect_to evaluation_signin_path(id: params[:id]), notice: I18n.t("banner.session.visitor")
    end

    def uploaded_evaluation_files
      @uploaded_evaluation_files ||= Support::EvaluatorsUploadDocument.where(support_case_id: params[:id], email: current_user.email)
    end
  end
end
