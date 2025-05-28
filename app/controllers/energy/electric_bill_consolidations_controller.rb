class Energy::ElectricBillConsolidationsController < Energy::ApplicationController
  before_action :organisation_details
  before_action :form, only: %i[update]
  before_action { @back_url = energy_case_org_electricity_meter_index_path }

  def show
    @form = Energy::ElectricBillConsolidationForm.new(**@onboarding_case_organisation.to_h.compact)
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

    energy_case_org_site_contact_details_path
  end

  def form
    @form = Energy::ElectricBillConsolidationForm.new(
      messages: validation.errors(full: true).to_h,
      **validation.to_h,
    )
  end

  def validation
    @validation ||= Energy::ElectricBillConsolidationFormSchema.new.call(**form_params)
  end

  def form_params
    params.fetch(:electric_bill_consolidation_form, {}).permit(*%i[is_electric_bill_consolidated])
  end
end
