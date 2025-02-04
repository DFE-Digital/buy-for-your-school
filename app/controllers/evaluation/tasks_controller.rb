module Evaluation
  class TasksController < ApplicationController
    before_action :authenticate_user!, only: %i[edit]
    before_action :set_current_case
    before_action :check_user_is_evaluator
    before_action :set_uploaded_documents
    before_action :set_downloaded_documents
    before_action :download_document_status

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

      redirect_to root_path, notice: I18n.t("evaluation.tasks.not_permitted")
    end

    def set_downloaded_documents
      @downloaded_documents = Support::EvaluatorsDownloadDocument.where(support_case_id: params[:id], email: current_user.email)
    end

    def set_uploaded_documents
      @documents = @current_case.upload_documents
    end

    def download_document_status
      @download_document_status = if @documents.count == @downloaded_documents.count && @documents.any?
                                    "complete"
                                  elsif @documents.count > @downloaded_documents.count && @downloaded_documents.any?
                                    "in_progress"
                                  else
                                    "to_do"
                                  end
    end

    def authenticate_user!
      super

      session[:email_evaluator_link] = evaluation_task_path(id: params[:id], host: request.host)
    end
  end
end
