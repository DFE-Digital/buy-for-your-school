class Energy::TaskList
  include ActiveModel::Model
  include Rails.application.routes.url_helpers

  DEFAULT_PATH = "/energy/onboarding".freeze

  def initialize(energy_onboarding_case_id)
    @energy_onboarding_case_id = energy_onboarding_case_id
  end

  def call
    [
      gas_contract_information,
      gas_meters_and_usage,
      electric_contract_information,
      electric_meters_and_usage,
      site_contact_details,
      vat_declaration,
      billing_preferences,
    ]
  end

  def gas_contract_information
    status = case_org.gas_current_supplier && case_org.gas_current_contract_end_date ? :completed : :not_started
    path = energy_case_gas_supplier_path(case_id: case_org.energy_onboarding_case_id)
    Task.new(title: __method__, status:, path:)
  end

  def gas_meters_and_usage
    status = case_org.gas_meters.any? ? :completed : :not_started
    path = energy_case_org_gas_meter_index_path(case_id: case_org.energy_onboarding_case_id, org_id: case_org.onboardable_id)
    Task.new(title: __method__, status:, path:)
  end

  def electric_contract_information
    status = case_org.electric_current_supplier && case_org.electric_current_contract_end_date ? :completed : :not_started
    path = energy_case_electric_supplier_path(case_id: case_org.energy_onboarding_case_id)
    Task.new(title: __method__, status:, path:)
  end

  def electric_meters_and_usage
    status = case_org.electricity_meters.any? ? :completed : :not_started
    path = energy_case_org_electricity_meter_index_path(case_id: case_org.energy_onboarding_case_id, org_id: case_org.onboardable_id)
    Task.new(title: __method__, status:, path:)
  end

  def site_contact_details
    status = :not_started
    path = DEFAULT_PATH
    Task.new(title: __method__, status:, path:)
  end

  def vat_declaration
    status = :in_progress
    path = DEFAULT_PATH
    Task.new(title: __method__, status:, path:)
  end

  def billing_preferences
    status = :not_started
    path = DEFAULT_PATH
    Task.new(title: __method__, status:, path:)
  end

private

  def case_org
    @case_org ||= Energy::OnboardingCaseOrganisation.includes(:gas_meters, :electricity_meters)
                                                    .find_by(energy_onboarding_case_id: @energy_onboarding_case_id)
  end

  class Task
    attr_accessor :title, :status, :path

    def initialize(title:, status: :not_started, path: "")
      @title = title
      @status = status
      @path = path
    end

    def status_colour
      case status
      when :completed
        "green"
      when :in_progress
        "blue"
      when :not_started
        "grey"
      else
        "grey"
      end
    end
  end
end
