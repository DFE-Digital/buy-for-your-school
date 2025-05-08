module Energy
  class GasSingleMultisController < ApplicationController
    before_action :organisation_details
    before_action { @back_url = energy_case_gas_supplier_path(onboarding_case) }
    before_action :form, only: %i[update]

    def show
      @form = Energy::GasSingleMultiForm.new(**@onboarding_case_organisation.to_h.compact)
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
      @form = Energy::GasSingleMultiForm.new(
        messages: validation.errors(full: true).to_h,
        **validation.to_h,
      )
    end

    def validation
      @validation ||= Energy::GasSingleMultiFormSchema.new.call(**form_params)
    end

    def form_params
      params.fetch(:gas_single_multi, {}).permit(:gas_single_multi)
    end

    def redirect_path
      return energy_case_tasks_path if going_to_tasks?

      new_energy_case_org_gas_meter_path(onboarding_case, @onboarding_case_organisation)
    end
  end
end
