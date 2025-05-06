class Energy::ElectricityMeterTypesController < Energy::ApplicationController
  before_action :organisation_details
  before_action :form, only: %i[update]
  before_action :electricity_meter_type
  before_action { @back_url = energy_case_org_gas_bill_consolidation_path }

  def show
    @form = Energy::ElectricityMeterTypeForm.new(**electricity_meter_type.to_h.compact)
  end

  def update
    if validation.success?
      electricity_meter_type.update!(**form.data)
      redirect_to redirect_path
    else
      render :show
    end
  end

private

  def electricity_meter_type
    @electricity_meter_type = Energy::OnboardingCaseOrganisation.find_by(energy_onboarding_case_id: params[:case_id], onboardable_id: params[:org_id])
  end

  def redirect_path
    params[:commit] == I18n.t("generic.button.save_continue") ? energy_case_org_electricity_meter_type_path : energy_case_tasks_path
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
