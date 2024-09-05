module Support
  class Cases::ContractsController < Cases::ApplicationController
    before_action :set_back_url, only: %i[edit update]

    include HasDateParams
    include Concerns::HasInteraction

    def edit
      @case_contracts_form = CaseContractsForm.new(**current_contract.to_h)

      render "support/cases/#{view_template}/edit"
    end

    def update
      @case_contracts_form = CaseContractsForm.from_validation(validation)

      if validation.success?
        current_contract.update!(@case_contracts_form.to_h)
        create_contract_interaction

        redirect_to @back_url, notice: I18n.t("support.case_contract.flash.updated")
      else
        render "support/cases/#{view_template}/edit"
      end
    end

  private

    # @return [String] "existing_contracts" or "new_contracts"
    def view_template
      current_contract.class.name.tableize.split("/").last
    end

    def validation
      @validation ||= CaseContractsFormSchema.new.call(**case_contracts_form_params)
    end

    def set_back_url
      @back_url = support_case_path(current_contract.support_case, anchor: "case-details")
    end

    def current_contract
      @current_contract ||= Support::Contract.for(params[:id])
    end

    def case_contracts_form_params
      form_params = params.require(:case_contracts_form).permit(:supplier, :spend, :duration, :is_supplier_sme)
      form_params[:started_at] = date_param(:case_contracts_form, :started_at)
      form_params[:ended_at] = date_param(:case_contracts_form, :ended_at)
      form_params
    end

    def create_contract_interaction
      current_contract.instance_of?(Support::ExistingContract) ? create_interaction(params[:case_id], "existing_contract_updated", "existing contract details updated") : create_interaction(params[:case_id], "new_contract_updated", "new contract details updated")
    end
  end
end
