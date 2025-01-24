module Evaluation
  class ApplicationController < ::ApplicationController
  protected

    def authenticate_user!
      return unless current_user.guest?

      session.delete(:dfe_sign_in_uid)

      if params[:controller] == "evaluation/tasks" && params[:action] == "edit"
        session[:email_evaluator_link] = evaluation_task_path(id: params[:id], host: request.host)
      end

      redirect_to root_path, notice: I18n.t("banner.session.visitor")
    end
  end
end
