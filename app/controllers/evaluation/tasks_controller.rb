module Evaluation
  class TasksController < ApplicationController
    before_action :check_user_is_evaluator

    def show; end

  private

    helper_method def current_evaluator
      @current_evaluator ||= Support::Evaluator.find(params[:id])
    end

    def check_user_is_evaluator
      return if current_user == current_evaluator.user

      redirect_to root_path, notice: I18n.t("evaluation.tasks.not_permitted")
    end
  end
end
