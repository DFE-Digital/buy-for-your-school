class Energy::SwitchEnergyController < ApplicationController
  before_action :check_flag
  before_action :form, only: %i[update]
  before_action :switching_energy
  before_action { @back_url = energy_switch_energy_path }
  def show
    @form = Energy::SwitchEnergyForm.new(**switching_energy.to_h.compact)
  end

  def update
    if validation.success?
      switching_energy.update!(**form.data)
      redirect_to energy_switch_energy_path
    else
      render :show
    end
  end

private

  def check_flag
    render "errors/not_found", status: :not_found unless Flipper.enabled?(:energy)
  end

  def switching_energy
    @switching_energy = Energy::OnboardingCaseOrganisation.find_by(id: params[:id])
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
