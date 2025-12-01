module Evaluation
  class SigninController < ApplicationController
    skip_before_action :authenticate_user!
    def show
      session.delete(:email_school_buyer_link)
      session.delete(:energy_case_tasks_path)
      session.delete(:energy_onboarding)
      session.delete(:faf_referrer)
      session[:email_evaluator_link] = evaluation_task_path(id: params[:id], host: request.host)
    end
  end
end
