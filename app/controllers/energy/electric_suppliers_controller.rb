module Energy
  class ElectricSuppliersController < ApplicationController
    include HasDateParams
    before_action :organisation_details
    before_action :form, only: %i[update]
    before_action { @back_url = set_back_url }

    def show
      @form = Energy::ElectricSupplierForm.new(**@onboarding_case_organisation.to_h.compact)
    end

    def update
      if validation.success?
        @onboarding_case_organisation.update!(**form.data)
        redirect_to redirect_path
        # single or multi meter site ticket controller
      else
        render :show
      end
    end

  private

    def form
      @form = Energy::ElectricSupplierForm.new(
        messages: validation.errors(full: true).to_h,
        **validation.to_h,
      )
    end

    def validation
      @validation ||= Energy::ElectricSupplierFormSchema.new.call(**form_params)
    end

    def form_params
      electric_supplier_params = params.fetch(:electric_supplier_form, {}).permit(*%i[electric_current_supplier electric_current_contract_end_date])
      electric_supplier_params[:electric_current_contract_end_date] = date_param(:electric_supplier_form, :electric_current_contract_end_date)
      electric_supplier_params
    end

    def redirect_path
      energy_case_org_gas_meter_index_path(case_id: params[:case_id], org_id: @onboarding_case_organisation.onboardable_id)
    end

    def set_back_url
      @onboarding_case_organisation.switching_energy_type_gas_electricity? ? energy_case_gas_supplier_path : energy_case_switch_energy_path
    end
  end
end
