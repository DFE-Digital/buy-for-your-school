class Energy::GasMeterController < Energy::ApplicationController
  before_action :organisation_details
  before_action :set_gas_meter_detail, only: %i[edit update destroy]

  before_action only: %i[index] do
    @back_url = energy_case_gas_supplier_path
  end

  before_action except: %i[index] do
    @back_url = energy_case_org_gas_meter_index_path
  end

  def index
    @gas_meter_details = @onboarding_case_organisation.gas_meters.all
  end

  def new
    @gas_meter_detail = @onboarding_case_organisation.gas_meters.new
  end

  def edit; end

  def create
    @gas_meter_detail = @onboarding_case_organisation.gas_meters.new(form_params)

    if @gas_meter_detail.save
      # redirect path will be updated later
      redirect_to redirect_path
    else
      render :new
    end
  end

  def update
    if @gas_meter_detail.update(form_params)
      # redirect path will be updated later
      redirect_to redirect_path
    else
      render :edit
    end
  end

  def destroy
    return unless params[:confirm]

    @gas_meter_detail.destroy!
    redirect_to energy_case_org_gas_meter_index_path,
                notice: I18n.t("energy.gas_meter_details.remove_page.removed")
  end

private

  def set_gas_meter_detail
    @gas_meter_detail = @onboarding_case_organisation.gas_meters.find(params[:id])
  end

  def redirect_path
    return energy_case_tasks_path if going_to_tasks?
    return energy_case_org_gas_meter_index_path(onboarding_case, @onboarding_case_organisation) if multiple_meters?
    return energy_case_electric_supplier_path(onboarding_case) if switching_both?

    # They must be switching gas only
    # Change this to Who manages site access? when we have the screen
    energy_case_org_gas_meter_path(onboarding_case, @onboarding_case_organisation)
  end

  def form_params
    params.fetch(:energy_gas_meter).permit(:mprn, :gas_usage)
  end
end
