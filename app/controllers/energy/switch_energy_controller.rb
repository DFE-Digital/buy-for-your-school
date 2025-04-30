class Energy::SwitchEnergyController < ApplicationController
  before_action :form, only: %i[update]
  before_action :switching_energy
  before_action :organisation_detail
  before_action { @back_url = energy_authorisation_path }

  ALLOWED_CLASSES = [
    "Support::Organisation",
    "Support::EstablishmentGroup",
  ].freeze

  def show
    @form = Energy::SwitchEnergyForm.new(**switching_energy.to_h.compact)
  end

  def update
    if validation.success?
      switching_energy.update!(**form.data)
      redirect_to redirect_path
    else
      render :show
    end
  end

private

  def switching_energy
    @switching_energy = Energy::OnboardingCaseOrganisation.find_by(energy_onboarding_case_id: params[:id])
  end

  def redirect_path
    params[:commit] == I18n.t("generic.button.save_continue") ? energy_switch_energy_path : energy_task_path
  end

  def organisation_detail
    onboardable_class = @switching_energy&.onboardable_type

    if ALLOWED_CLASSES.include?(onboardable_class)
      @organisation_detail = onboardable_class.safe_constantize.find(@switching_energy.onboardable_id)
    else
      render("errors/not_found", status: :not_found)
    end
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
