module Energy
  class GasSuppliersController < ApplicationController
    include HasDateParams
    before_action :organisation_details
    before_action :form, only: %i[update]

    before_action { @back_url = energy_case_switch_energy_path }

    def show
      @form = Energy::GasSupplierForm.new(**@onboarding_case_organisation.to_h.compact)
    end

    def update
      if validation.success?
        @onboarding_case_organisation.update!(**form.data)
        redirect_to energy_case_gas_supplier_path
      else
        render :show
      end
    end

  private

    def form
      @form = Energy::GasSupplierForm.new(
        messages: validation.errors(full: true).to_h,
        **validation.to_h,
      )
    end

    def validation
      @validation ||= Energy::GasSupplierFormSchema.new.call(**form_params)
    end

    def form_params
      gas_supplier_params = params.fetch(:gas_supplier_form, {}).permit(*%i[gas_current_supplier gas_current_contract_end_date])
      gas_supplier_params[:gas_current_contract_end_date] = date_param(:gas_supplier_form, :gas_current_contract_end_date)
      gas_supplier_params
    end
  end
end
