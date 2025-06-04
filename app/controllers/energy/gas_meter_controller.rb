class Energy::GasMeterController < Energy::ApplicationController
  before_action :organisation_details
  before_action :add_another_mprn_enabled?
  before_action :set_gas_meter_detail, only: %i[edit update destroy]
  before_action :back_url

  def index
    @gas_meter_details = @onboarding_case_organisation.gas_meters.order(created_at: :asc)
  end

  def new
    if @onboarding_case_organisation.gas_meters.count == MAX_METER_COUNT
      redirect_to energy_case_org_gas_meter_index_path,
                  notice: I18n.t("energy.gas_meter_details.alert.limit_reached")
    end

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
    redirect_to energy_case_org_gas_meter_index_path(**@routing_flags),
                notice: I18n.t("energy.gas_meter_details.remove_page.removed")
  end

private

  helper_method def add_another_mprn_enabled?
    gas_multiple_meters? || !gas_meter_usage_exist?
  end

  def set_gas_meter_detail
    @gas_meter_detail = @onboarding_case_organisation.gas_meters.find(params[:id])
  end

  def redirect_path
    if going_to_tasks?
      energy_case_tasks_path
    elsif from_check? && gas_single_meter?
      energy_case_check_your_answers_path
    elsif switching_both? && gas_single_meter?
      energy_case_org_electricity_meter_type_path
    else
      energy_case_org_gas_meter_index_path(onboarding_case, @onboarding_case_organisation, **@routing_flags)
    end
  end

  def back_url
    @back_url =
      case action_name.to_sym
      when :index
        edit_energy_case_org_gas_meter_path(onboarding_case, @onboarding_case_organisation, gas_meter_usage_details.last) if gas_meter_usage_exist?
        new_energy_case_org_gas_meter_path
      when :edit, :new
        params[:return_to] == "summary" ? energy_case_org_gas_meter_index_path : energy_case_org_gas_single_multi_path
      when :create, :update
        gas_multiple_meters? ? energy_case_org_gas_meter_index_path : energy_case_org_gas_single_multi_path
      when :destroy
        energy_case_org_gas_meter_index_path
      end
  end

  def form_params
    params.fetch(:energy_gas_meter).permit(:mprn, :gas_usage)
  end
end
