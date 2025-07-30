class Energy::SiteContactDetailsController < Energy::ApplicationController
  before_action :organisation_details
  before_action :form, only: %i[update]
  before_action :back_url, :form_url

  def show
    @form = Energy::SiteContactDetailsForm.new(**@onboarding_case_organisation.to_h.compact)
  end

  def update
    if validation.success?
      sanitized_data = form.data
      sanitized_data[:site_contact_phone] = sanitized_data[:site_contact_phone].gsub(/\D/, "")

      @onboarding_case_organisation.update!(**sanitized_data)
      redirect_to redirect_path
    else
      render :show
    end
  end

private

  def form
    @form = Energy::SiteContactDetailsForm.new(
      messages: validation.errors(full: true).to_h,
      **validation.to_h,
    )
  end

  def validation
    @validation ||= Energy::SiteContactDetailsFormSchema.new.call(**form_params)
  end

  def form_params
    params
      .fetch(:site_contact_details_form, {})
      .permit(
        :site_contact_first_name,
        :site_contact_last_name,
        :site_contact_email,
        :site_contact_phone,
      )
  end

  def edit_gas_usage_path
    edit_energy_case_org_gas_meter_path(onboarding_case, @onboarding_case_organisation, gas_meter_usage_details.first)
  end

  def new_gas_usage_path
    new_energy_case_org_gas_meter_path(onboarding_case, @onboarding_case_organisation)
  end

  def edit_electricity_usage_path
    edit_energy_case_org_electricity_meter_path(onboarding_case, @onboarding_case_organisation, electricity_usage_details.first)
  end

  def new_electricity_usage_path
    new_energy_case_org_electricity_meter_path(onboarding_case, @onboarding_case_organisation)
  end

  def back_url
    @back_url = if from_tasks?
                  energy_case_tasks_path
                elsif switching_gas? && gas_multiple_meters?
                  energy_case_org_gas_bill_consolidation_path
                elsif switching_gas? && !gas_multiple_meters?
                  gas_meter_usage_exist? ? edit_gas_usage_path : new_gas_usage_path
                elsif electricity_multiple_meters?
                  energy_case_org_electric_bill_consolidation_path
                else
                  electricity_usage_exist? ? edit_electricity_usage_path : new_electricity_usage_path
                end
  end

  def form_url
    @form_url = energy_case_org_site_contact_details_path(**@routing_flags)
  end

  def redirect_path
    return energy_case_tasks_path if going_to_tasks? || from_tasks?
    return energy_case_check_your_answers_path if from_check?

    energy_case_org_vat_rate_charge_path
  end
end
