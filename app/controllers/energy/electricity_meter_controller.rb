class Energy::ElectricityMeterController < Energy::ApplicationController
  before_action :organisation_details
  before_action :electricity_meter_detail, only: %i[edit update destroy]

  before_action only: %i[index] do
    @back_url = energy_case_org_electricity_meter_type_path
  end

  before_action except: %i[index] do
    @back_url = energy_case_org_electricity_meter_index_path
  end

  def index
    @electricity_meter_details = @onboarding_case_organisation.electricity_meters.all
  end

  def new
    @electricity_meter_detail = @onboarding_case_organisation.electricity_meters.new
  end

  def edit; end

  def create
    @electricity_meter_detail = @onboarding_case_organisation.electricity_meters.new(form_params)

    if @electricity_meter_detail.save
      # redirect path will be updated later
      redirect_to redirect_path
    else
      render :new
    end
  end

  def update
    if @electricity_meter_detail.update(form_params)
      # redirect path will be updated later
      redirect_to redirect_path
    else
      render :edit
    end
  end

  def destroy
    return unless params[:confirm]

    @electricity_meter_detail.destroy!
    redirect_to energy_case_org_gas_meter_index_path,
                notice: I18n.t("energy.electricity_meter.remove_page.removed")
  end

private

  def electricity_meter_detail
    @electricity_meter_detail = @onboarding_case_organisation.electricity_meters.find(params[:id])
  end

  def redirect_path
    params[:commit] == I18n.t("generic.button.save_continue") ? energy_case_org_electricity_meter_index_path : energy_case_tasks_path
  end

  def form_params
    params.fetch(:energy_electricity_meter).permit(:mpan, :is_half_hourly, :supply_capacity, :data_aggregator, :data_collector, :meter_operator, :electricity_usage)
  end
end
