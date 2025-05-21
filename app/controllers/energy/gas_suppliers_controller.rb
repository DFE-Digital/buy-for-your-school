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
        redirect_to redirect_path
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
      gas_supplier_params = params.fetch(:gas_supplier_form, {}).permit(*%i[gas_current_supplier gas_current_contract_end_date gas_current_supplier_other])
      gas_supplier_params[:gas_current_contract_end_date] = date_param(:gas_supplier_form, :gas_current_contract_end_date)
      gas_supplier_params
    end

    def redirect_path
      return energy_case_tasks_path if going_to_tasks? || from_tasks?
      return energy_case_check_your_answers_path if from_check?
      return energy_case_org_gas_single_multi_path(onboarding_case, @onboarding_case_organisation) if switching_gas?

      # They must be switching both
      energy_case_electric_supplier_path(onboarding_case)
    end
  end
end
