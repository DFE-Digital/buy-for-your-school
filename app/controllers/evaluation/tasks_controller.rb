module Evaluation
  class TasksController < ApplicationController
    before_action :set_current_case
    before_action :check_user_is_evaluator

    def edit
      session[:email_evaluator_link] = evaluation_task_path(@current_case, host: request.host)
      redirect_to evaluation_task_path(@current_case)
    end

    def show; end

  private

    helper_method def current_evaluator
      @current_evaluator ||= Support::Evaluator.find_by(support_case_id: params[:id], email: current_user.email)
    end

    def set_current_case
      @current_case = Support::Case.find(params[:id])
      @evaluation_due_date = @current_case.evaluation_due_date.strftime("%d %B %Y")
    end

    def check_user_is_evaluator
      return if current_user == current_evaluator.user

      redirect_to root_path, notice: I18n.t("evaluation.tasks.not_permitted")
    end
  end
end
