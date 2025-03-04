module MyProcurements
  class TasksController < ApplicationController
    before_action :authenticate_user!, only: %i[edit]
    before_action :set_current_case
    before_action :check_user_is_school_buying_professional

    def edit
      session[:email_sbp_link] = my_procurements_task_path(@current_case, host: request.host)
      redirect_to my_procurements_task_path(@current_case)
    end

    def show; end

  private

    helper_method def school_buying_professional
      return @school_buying_professional if defined? @school_buying_professional

      @school_buying_professional = Support::ContractRecipient.where("support_case_id = ? AND LOWER(email) = LOWER(?)", params[:id], current_user.email).first
    end

    def set_current_case
      @current_case = Support::Case.find(params[:id])
    end

    def check_user_is_school_buying_professional
      return if school_buying_professional.present? && current_user.email.downcase == school_buying_professional.email.downcase

      redirect_to root_path, notice: I18n.t("my_procurements.tasks.not_permitted")
    end

    def authenticate_user!
      super

      session[:email_sbp_link] = my_procurements_task_path(id: params[:id], host: request.host)
    end
  end
end
