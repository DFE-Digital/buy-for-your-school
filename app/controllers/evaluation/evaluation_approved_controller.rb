module Evaluation
  class EvaluationApprovedController < ApplicationController
    before_action :set_current_case
    before_action :check_user_is_evaluator
    before_action { @back_url = evaluation_task_path(@current_case) }

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
  end
end
