module Evaluation
  class SigninController < ApplicationController
    skip_before_action :authenticate_user!
    def show
      @start_now_button_route = current_user.guest? ? "/auth/dfe" : dashboard_path
      @start_now_button_method = current_user.guest? ? :post : :get
      session[:email_evaluator_link] = evaluation_task_path(id: params[:id], host: request.host)
    end
  end
end
