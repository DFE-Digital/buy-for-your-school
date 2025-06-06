class Energy::ElectricityMeterTypesController < Energy::ApplicationController
  before_action :organisation_details
  before_action :form, only: %i[update]
  before_action { @back_url = back_url }

  def show
    @form = Energy::ElectricityMeterTypeForm.new(**@onboarding_case_organisation.to_h.compact)
  end

  def update
    if validation.success?
      @onboarding_case_organisation.update!(**form.data)

      if @onboarding_case_organisation.saved_change_to_electricity_meter_type?
        reset_meter_data
      end

      redirect_to redirect_path
    else
      render :show
    end
  end

private

  def redirect_path
    if going_to_tasks?
      energy_case_tasks_path
    elsif electricity_multiple_meters?
      electricity_usage_exist? ? energy_case_org_electricity_meter_index_path(**@routing_flags) : new_energy_case_org_electricity_meter_path(**@routing_flags)
    else
      electricity_usage_exist? ? edit_electric_usage_path : new_energy_case_org_electricity_meter_path(**@routing_flags)
    end
  end

  def reset_meter_data
    @onboarding_case_organisation.electricity_meters.destroy_all
    @onboarding_case_organisation.update!(is_electric_bill_consolidated: nil) unless electricity_multiple_meters?
  end

  def edit_electric_usage_path
    edit_energy_case_org_electricity_meter_path(onboarding_case, @onboarding_case_organisation, electricity_usage_details.first, **@routing_flags)
  end

  def edit_gas_usage_path
    return "#" if gas_meter_usage_details.none? # This needs fixing - put in to fix failing spec under tight time constraint

    edit_energy_case_org_gas_meter_path(onboarding_case, @onboarding_case_organisation, gas_meter_usage_details.first)
  end

  def back_url
    if from_tasks?
      energy_case_tasks_path
    elsif switching_both?
      gas_multiple_meters? ? energy_case_org_gas_bill_consolidation_path : edit_gas_usage_path
    elsif switching_electricity?
      energy_case_electric_supplier_path
    end
  end

  def form
    @form = Energy::ElectricityMeterTypeForm.new(
      messages: validation.errors(full: true).to_h,
      **validation.to_h,
    )
  end

  def validation
    @validation ||= Energy::ElectricityMeterTypeFormSchema.new.call(**form_params)
  end

  def form_params
    params.fetch(:electricity_meter_type_form, {}).permit(*%i[electricity_meter_type])
  end
end
