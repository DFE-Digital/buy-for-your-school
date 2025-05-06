class Energy::GasBillConsolidationsController < Energy::ApplicationController
  before_action :organisation_details
  before_action :form, only: %i[update]
  before_action :gas_bill_consolidation
  before_action { @back_url = energy_case_org_gas_meter_index_path }

  def show
    @form = Energy::GasBillConsolidationForm.new(**gas_bill_consolidation.to_h.compact)
  end

  def update
    if validation.success?
      gas_bill_consolidation.update!(**form.data)
      redirect_to redirect_path
    else
      render :show
    end
  end

private

  def gas_bill_consolidation
    @gas_bill_consolidation = Energy::OnboardingCaseOrganisation.find_by(energy_onboarding_case_id: params[:case_id], onboardable_id: params[:org_id])
  end

  def redirect_path
    params[:commit] == I18n.t("generic.button.save_continue") ? energy_case_org_gas_bill_consolidation_path : energy_case_tasks_path
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
