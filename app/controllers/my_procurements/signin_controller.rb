module MyProcurements
  class SigninController < ApplicationController
    skip_before_action :authenticate_user!
    def show
      session.delete(:email_evaluator_link)
      session.delete(:energy_case_tasks_path)
      session.delete(:energy_onboarding)
      session.delete(:faf_referrer)
      session[:email_school_buyer_link] = my_procurements_task_path(id: params[:id], host: request.host)
      session[:school_buyer_signin_link] = my_procurements_signin_path(id: params[:id])
    end
  end
end
