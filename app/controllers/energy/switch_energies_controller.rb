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
      redirect_to redirect_path
    else
      render :show
    end
  end

private

  def redirect_path
    return energy_case_tasks_path if going_to_tasks?
    return energy_case_electric_supplier_path(onboarding_case) if switching_electricity?

    # They must be switching both or gas only
    energy_case_gas_supplier_path(onboarding_case)
  end

  def energy_supplier_path
    @onboarding_case_organisation.switching_energy_type_electricity? ? energy_case_electric_supplier_path : energy_case_gas_supplier_path
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
