class Energy::ElectricityMeterController < Energy::ApplicationController
  before_action :organisation_details
  before_action :add_another_mpan_enabled?
  before_action :electricity_meter_detail, only: %i[edit update destroy]
  before_action :back_url

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
    redirect_to energy_case_org_electricity_meter_index_path,
                notice: I18n.t("energy.electricity_meter.remove_page.removed")
  end

private

  helper_method def add_another_mpan_enabled?
    electricity_multiple_meters? || !electricity_usage_exist?
  end

  def electricity_meter_detail
    @electricity_meter_detail = @onboarding_case_organisation.electricity_meters.find(params[:id])
  end

  def redirect_path
    return energy_case_tasks_path if going_to_tasks?

    energy_case_org_electricity_meter_index_path
  end

  def form_params
    params.fetch(:energy_electricity_meter).permit(:mpan, :is_half_hourly, :supply_capacity, :data_aggregator, :data_collector, :meter_operator, :electricity_usage)
  end

  def back_url
    @back_url =
      case action_name.to_sym
      when :index
        edit_energy_case_org_electricity_meter_path(onboarding_case, @onboarding_case_organisation, electricity_usage_details.last)
      when :edit, :new
        params[:return_to] == "summary" ? energy_case_org_electricity_meter_index_path : energy_case_org_electricity_meter_type_path
      when :create, :update
        electricity_multiple_meters? ? energy_case_org_electricity_meter_index_path : energy_case_org_electricity_meter_type_path
      when :destroy
        energy_case_org_electricity_meter_index_path
      end
  end
end
