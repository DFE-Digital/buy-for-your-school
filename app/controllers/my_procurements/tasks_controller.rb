module MyProcurements
  class TasksController < ApplicationController
    before_action :authenticate_user!, only: %i[edit]
    before_action :set_current_case
    before_action :check_user_is_school_buying_professional
    before_action :set_uploaded_handover_packs
    before_action :set_downloaded_handover_packs
    before_action :downloaded_handover_pack_status

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

    def set_uploaded_handover_packs
      @uploaded_handover_packs = @current_case.upload_contract_handovers
    end

    def set_downloaded_handover_packs
      @downloaded_handover_packs = Support::DownloadContractHandover.where(support_case_id: params[:id], email: current_user.email)
    end

    def downloaded_handover_pack_status
      @downloaded_handover_pack_status = if @uploaded_handover_packs.count == @downloaded_handover_packs.count && @uploaded_handover_packs.any?
                                           :complete
                                         elsif @uploaded_handover_packs.count > @downloaded_handover_packs.count && @downloaded_handover_packs.any?
                                           :in_progress
                                         else
                                           :to_do
                                         end
    end
  end
end
