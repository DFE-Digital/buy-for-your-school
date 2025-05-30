class Energy::SwitchEnergiesController < Energy::ApplicationController
  before_action :organisation_details
  before_action :form, only: %i[update]
  before_action { @back_url = energy_school_selection_path }

  def show
    @form = Energy::SwitchEnergyForm.new(**@onboarding_case_organisation.to_h.compact)
  end

  def update
    if validation.success?
      @onboarding_case_organisation.update!(**form.data)

      if @onboarding_case_organisation.saved_change_to_switching_energy_type?
        reset_energy_data
      end

      redirect_to redirect_path
    else
      render :show
    end
  end

private

  def redirect_path
    return energy_case_electric_supplier_path(onboarding_case) if switching_electricity?

    # They must be switching both or gas only
    energy_case_gas_supplier_path(onboarding_case)
  end

  def reset_energy_data
    if switching_electricity?
      reset_gas_data
    elsif switching_gas?
      reset_electricity_data
    end
  end

  def reset_gas_data
    @onboarding_case_organisation.update!(reset_gas_params)
    @onboarding_case_organisation.gas_meters.destroy_all
  end

  def reset_electricity_data
    @onboarding_case_organisation.update!(reset_electricity_params)
    @onboarding_case_organisation.electricity_meters.destroy_all
  end

  def reset_gas_params
    {
      gas_current_supplier: nil,
      gas_current_supplier_other: nil,
      gas_current_contract_end_date: nil,
      gas_single_multi: nil,
      gas_bill_consolidation: nil,

    }
  end

  def reset_electricity_params
    {
      electric_current_supplier: nil,
      electric_current_supplier_other: nil,
      electric_current_contract_end_date: nil,
      electricity_meter_type: nil,
      is_electric_bill_consolidated: nil,
    }
  end

  def form
    @form = Energy::SwitchEnergyForm.new(
      messages: validation.errors(full: true).to_h,
      **validation.to_h,
    )
  end

  def validation
    @validation ||= Energy::SwitchEnergyFormSchema.new.call(**form_params)
  end

  def form_params
    params.fetch(:energy_type_form, {}).permit(*%i[switching_energy_type])
  end
end
