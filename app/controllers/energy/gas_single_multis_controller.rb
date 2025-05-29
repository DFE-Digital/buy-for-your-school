module Energy
  class GasSingleMultisController < ApplicationController
    before_action :organisation_details
    before_action :back_url
    before_action :form, only: %i[update]

    def show
      @form = Energy::GasSingleMultiForm.new(**@onboarding_case_organisation.to_h.compact)
    end

    def update
      if validation.success?
        @onboarding_case_organisation.update!(**form.data)

        if @onboarding_case_organisation.saved_change_to_gas_single_multi?
          reset_meter_data
        end

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
      if going_to_tasks?
        energy_case_tasks_path
      elsif gas_multiple_meters?
        gas_meter_usage_exist? ? energy_case_org_gas_meter_index_path : new_gas_usage_path
      else
        gas_meter_usage_exist? ? edit_gas_usage_path : new_gas_usage_path
      end
    end

    def reset_meter_data
      @onboarding_case_organisation.gas_meters.destroy_all
      @onboarding_case_organisation.update!(gas_bill_consolidation: nil) unless gas_multiple_meters?
    end

    def edit_gas_usage_path
      edit_energy_case_org_gas_meter_path(onboarding_case, @onboarding_case_organisation, gas_meter_usage_details.first)
    end

    def new_gas_usage_path
      new_energy_case_org_gas_meter_path(onboarding_case, @onboarding_case_organisation)
    end

    def back_url
      @back_url = if params[:return_to] == "tasks"
                    energy_case_tasks_path
                  else
                    switching_both? ? energy_case_electric_supplier_path(onboarding_case) : energy_case_gas_supplier_path(onboarding_case)
                  end
    end
  end
end
