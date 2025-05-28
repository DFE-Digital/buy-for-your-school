module Energy
  class ElectricSuppliersController < ApplicationController
    include HasDateParams
    before_action :organisation_details
    before_action :form, only: %i[update]
    before_action :back_url, :form_url

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
      electric_supplier_params = params.fetch(:electric_supplier_form, {}).permit(*%i[electric_current_supplier electric_current_contract_end_date electric_current_supplier_other])
      electric_supplier_params[:electric_current_contract_end_date] = date_param(:electric_supplier_form, :electric_current_contract_end_date)
      electric_supplier_params
    end

    def back_url
      @back_url = if @onboarding_case_organisation.switching_energy_type_gas_electricity?
                    energy_case_gas_supplier_path
                  else
                    energy_case_switch_energy_path
                  end
    end

    def form_url
      @form_url = energy_case_electric_supplier_path(return_to: params[:return_to], **@routing_flags)
    end

    def redirect_path
      return energy_case_tasks_path if going_to_tasks? || from_tasks?
      return energy_case_check_your_answers_path if from_check?
      return energy_case_org_electricity_meter_type_path(onboarding_case, @onboarding_case_organisation) if switching_electricity?

      # They must be switching both
      energy_case_org_gas_single_multi_path(onboarding_case, @onboarding_case_organisation)
    end
  end
end
