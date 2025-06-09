class Energy::GasBillConsolidationsController < Energy::ApplicationController
  before_action :organisation_details
  before_action :form, only: %i[update]
  before_action { @back_url = energy_case_org_gas_meter_index_path }

  def show
    @form = Energy::GasBillConsolidationForm.new(**@onboarding_case_organisation.to_h.compact)
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
    return energy_case_tasks_path if going_to_tasks? || from_tasks?
    return energy_case_check_your_answers_path if from_check?
    return energy_case_org_electricity_meter_type_path if switching_both?

    energy_case_org_site_contact_details_path
  end

  def form
    @form = Energy::GasBillConsolidationForm.new(
      messages: validation.errors(full: true).to_h,
      **validation.to_h,
    )
  end

  def validation
    @validation ||= Energy::GasBillConsolidationFormSchema.new.call(**form_params)
  end

  def form_params
    params.fetch(:gas_bill_consolidation_form, {}).permit(*%i[gas_bill_consolidation])
  end
end
