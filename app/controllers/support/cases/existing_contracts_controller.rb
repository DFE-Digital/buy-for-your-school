#edit
#update
module Support
  class Cases::ExistingContractsController < Cases::ApplicationController
    before_action :set_back_url, only: [:edit, :update]

    def edit
      @case_contracts_form = CaseContractsForm.new(**current_case.existing_contract.attributes.symbolize_keys)
    end

    def update
      @case_contracts_form = CaseContractsForm.from_validation(validation)
      if validation.success?
        current_case.existing_contract.update!(@case_contracts_form.as_json.except("messages"))

        redirect_to @back_url, notice: I18n.t("support.case_contracts.flash.updated")
      else
        render :edit
      end
    end

  private

    def validation
      @validation ||= CaseContractsFormSchema.new.call(**case_contracts_form_params)
    end

    def set_back_url
      @back_url = support_case_path(@current_case, anchor: "procurement-details")
    end

    def case_contracts_form_params
      params
        .require(:case_contracts_form)
        .permit(
          :type,
          :supplier,
          :started_at,
          :ended_at,
          :spend,
        )
    end

  end
end