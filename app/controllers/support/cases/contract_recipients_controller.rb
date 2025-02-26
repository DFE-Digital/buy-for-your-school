module Support
  class Cases::ContractRecipientsController < Cases::ApplicationController
    before_action :set_current_case
    before_action :set_contract_recipient, only: %i[edit update destroy]

    before_action only: %i[new create edit update destroy] do
      @back_url = support_case_contract_recipients_path(@current_case)
    end

    before_action only: [:index] do
      @back_url = support_case_path(@current_case, anchor: "tasklist")
    end
    def index
      @contract_recipients = @current_case.contract_recipients.all
    end

    def new
      @contract_recipient = @current_case.contract_recipients.new
    end

    def create
      @contract_recipient = @current_case.contract_recipients.new(contract_recipient_params)

      if @contract_recipient.save
        redirect_to support_case_contract_recipients_path(case_id: @current_case),
                    notice: I18n.t("support.contract_recipients.flash.success", name: @contract_recipient.name)
      else
        render :new
      end
    end

    def edit; end

    def update
      if @contract_recipient.update(contract_recipient_params)
        redirect_to support_case_contract_recipients_path(case_id: @current_case),
                    notice: I18n.t("support.contract_recipients.flash.updated", name: @contract_recipient.name)
      else
        render :edit
      end
    end

    def destroy
      return unless params[:confirm]

      @contract_recipient.destroy!
      redirect_to support_case_contract_recipients_path(case_id: @current_case),
                  notice: I18n.t("support.contract_recipients.flash.destroyed", name: @contract_recipient.name)
    end

  private

    def set_contract_recipient
      @contract_recipient = current_case.contract_recipients.find(params[:id])
    end

    def set_current_case
      @current_case = Support::Case.find(params[:case_id])
    end

    def contract_recipient_params
      params.require(:support_contract_recipient).permit(:first_name, :last_name, :email)
    end
  end
end
