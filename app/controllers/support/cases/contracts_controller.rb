module Support
  class Cases::ContractsController < Cases::ApplicationController
    before_action :set_back_url, only: %i[edit update]

    include Concerns::HasDateParams

    def edit
      @case_contracts_form = CaseContractsForm.new(**contract_params)

      edit_view
    end

    def update
      @case_contracts_form = CaseContractsForm.from_validation(validation)
      if validation.success?
        current_contract.update!(@case_contracts_form.to_h)

        redirect_to @back_url, notice: I18n.t("support.case_contract.flash.updated")
      else
        edit_view
      end
    end

  private

    def edit_view
      case current_contract.type
      when "Support::ExistingContract"
        render "support/cases/existing_contracts/edit"
      when "Support::NewContract"
        render "support/cases/new_contracts/edit"
      end
    end

    def validation
      @validation ||= CaseContractsFormSchema.new.call(**case_contracts_form_params)
    end

    def set_back_url
      @back_url = support_case_path(current_contract.support_case, anchor: "procurement-details")
    end

    def contract_params
      current_contract.attributes.symbolize_keys.merge(
        duration_in_months: current_contract.duration_in_months,
      )
    end

    def current_contract
      @current_contract ||= Support::Contract.for(params[:id])
    end

    def modify_date
      params[:case_contracts_form][:started_at] = date_param(:case_contracts_form, :started_at).to_s
      params[:case_contracts_form][:ended_at] = date_param(:case_contracts_form, :ended_at).to_s
    end

    def case_contracts_form_params
      modify_date
      params
        .require(:case_contracts_form)
        .permit(
          :supplier,
          :started_at,
          :ended_at,
          :spend,
          :duration_in_months,
        )
    end
  end
end
