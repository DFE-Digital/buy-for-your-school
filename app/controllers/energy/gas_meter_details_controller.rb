class Energy::GasMeterDetailsController < Energy::ApplicationController
  before_action :organisation_details
  before_action :set_gas_meter_detail, only: %i[edit update]
  before_action { @back_url = energy_switch_energy_path(id: params[:onboarding_case_id]) }
  def new
    @gas_meter_detail = @onboarding_organisation.gas_meters.new
  end

  def edit; end

  def create
    @gas_meter_detail = @onboarding_organisation.gas_meters.new(form_params)

    if @gas_meter_detail.save
      # redirect path will be updated later
      redirect_to energy_task_path(id: params[:onboarding_case_id])
    else
      render :new
    end
  end

  def update
    if @gas_meter_detail.update(form_params)
      # redirect path will be updated later
      redirect_to energy_task_path(id: params[:onboarding_case_id])
    else
      render :edit
    end
  end

private

  def set_gas_meter_detail
    @gas_meter_detail = @onboarding_organisation.gas_meters.find(params[:id])
  end

  def form_params
    params.fetch(:energy_gas_meter).permit(:mprn, :gas_usage)
  end
end
