class Energy::TaskList
  include ActiveModel::Model
  include Rails.application.routes.url_helpers
  include AddressHelper

  DEFAULT_PATH = "/energy/onboarding".freeze

  attr_accessor :context

  # This needs to be called for each onboarding org when we do MAT flow
  # While we're only doing single flow, we can keep using onboarding case but when
  # we do MAT flow, param needs to be changed to onboarding org
  def initialize(energy_onboarding_case_id, context: "tasks")
    @energy_onboarding_case_id = energy_onboarding_case_id
    @context = context == "tasks" ? :tasks : :check
    build_task_list
  end

  def org_name
    case_org.name
  end

  def call
    @static_list
  end

  def sections
    @static_list
  end

private

  def build_task_list
    @static_list = [
      switching_gas? ? gas_contract_information : nil,
      switching_electricity? ? electric_contract_information : nil,
      switching_gas? ? gas_meters_and_usage : nil,
      switching_electricity? ? electric_meters_and_usage : nil,
      site_contact_details,
      vat_declaration,
      billing_preferences,
    ].compact
  end

  def switching_gas?
    case_org.switching_energy_type_gas? || case_org.switching_energy_type_gas_electricity?
  end

  def switching_electricity?
    case_org.switching_energy_type_electricity? || case_org.switching_energy_type_gas_electricity?
  end

  def date_format(val)
    return "" if val.blank?

    val.strftime("%d-%m-%Y")
  end

  def gas_contract_information
    status = case_org.gas_current_supplier && case_org.gas_current_contract_end_date ? :complete : :not_started
    path = energy_case_gas_supplier_path(case_id: case_org.energy_onboarding_case_id, context => "1")
    Task.new(title: __method__, status:, path:).tap do |t|
      if case_org.gas_current_supplier == "other"
        t.add_attribute :gas_current_supplier_other, case_org
      else
        t.add_attribute :gas_current_supplier, case_org, text: I18n.t("energy.suppliers.#{case_org.gas_current_supplier}")
      end
      t.add_attribute :gas_current_contract_end_date, case_org, text: date_format(case_org.gas_current_contract_end_date)
    end
  end

  def gas_meters_and_usage
    status = any_gas_meters? ? :complete : :not_started
    path = if gas_single? || (context_tasks? && gas_multi? && no_gas_meters?)
             energy_case_org_gas_single_multi_path(case_id: case_org.energy_onboarding_case_id, org_id: case_org.onboardable_id, context => "1")
           else
             energy_case_org_gas_meter_index_path(case_id: case_org.energy_onboarding_case_id, org_id: case_org.onboardable_id, context => "1")
           end
    Task.new(title: __method__, status:, path:).tap do |t|
      t.add_attribute(:gas_single_multi, case_org, text: I18n.t("energy.check_your_answers.gas_meters_and_usage.#{case_org.gas_single_multi}"))

      case_org.gas_meters.each_with_index do |meter, _i|
        t.add_attribute(:mprn, meter)
        t.add_attribute(:gas_usage, meter)
      end

      t.add_attribute(:gas_bill_consolidation, case_org, text: case_org.gas_bill_consolidation ? I18n.t("generic.yes") : I18n.t("generic.no"))
    end
  end

  def electric_contract_information
    status = case_org.electric_current_supplier && case_org.electric_current_contract_end_date ? :complete : :not_started
    path = energy_case_electric_supplier_path(case_id: case_org.energy_onboarding_case_id, context => "1")
    Task.new(title: __method__, status:, path:).tap do |t|
      if case_org.electric_current_supplier == "other"
        t.add_attribute :electric_current_supplier_other, case_org
      else
        t.add_attribute :electric_current_supplier, case_org, text: I18n.t("energy.suppliers.#{case_org.electric_current_supplier}")
      end
      t.add_attribute :electric_current_contract_end_date, case_org, text: date_format(case_org.electric_current_contract_end_date)
    end
  end

  def electric_meters_and_usage
    status = case_org.electricity_meters.any? ? :complete : :not_started
    path = if elec_single? || (context_tasks? && elec_multi? && no_elec_meters?)
             energy_case_org_electricity_meter_type_path(case_id: case_org.energy_onboarding_case_id, org_id: case_org.onboardable_id, context => "1")
           else
             energy_case_org_electricity_meter_index_path(case_id: case_org.energy_onboarding_case_id, org_id: case_org.onboardable_id, context => "1")
           end

    Task.new(title: __method__, status:, path:).tap do |t|
      t.add_attribute(:electricity_meter_type, case_org, text: I18n.t("energy.check_your_answers.electric_meters_and_usage.#{case_org.electricity_meter_type}"))

      case_org.electricity_meters.each do |meter|
        t.add_attribute(:mpan, meter)
        t.add_attribute(:is_half_hourly, meter, text: meter.is_half_hourly ? I18n.t("generic.yes") : I18n.t("generic.no"))

        next unless meter.is_half_hourly

        t.add_attribute(:supply_capacity, meter)
        t.add_attribute(:data_aggregator, meter)
        t.add_attribute(:data_collector, meter)
        t.add_attribute(:meter_operator, meter)
      end

      t.add_attribute(:is_electric_bill_consolidated, case_org, text: case_org.is_electric_bill_consolidated ? I18n.t("generic.yes") : I18n.t("generic.no"))
    end
  end

  def site_contact_details
    status = case_org.site_contact_email? ? :complete : :not_started
    path = energy_case_org_site_contact_details_path(case_id: case_org.energy_onboarding_case_id, org_id: case_org.onboardable_id, context => "1")
    Task.new(title: __method__, status:, path:).tap do |t|
      t.add_attribute(:site_contact_first_name, case_org)
      t.add_attribute(:site_contact_last_name, case_org)
      t.add_attribute(:site_contact_email, case_org)
      t.add_attribute(:site_contact_phone, case_org)
    end
  end

  def vat_declaration
    status = case_org.vat_rate ? :complete : :not_started
    path = energy_case_org_vat_rate_charge_path(case_org.onboarding_case, case_org, context => "1")
    Task.new(title: __method__, status:, path:).tap do |t|
      t.add_attribute(:vat_rate, case_org, text: "#{case_org.vat_rate}%")

      if case_org.vat_rate == 5
        t.add_attribute(:vat_lower_rate_percentage, case_org)
        t.add_attribute(:vat_lower_rate_reg_no, case_org)

        if case_org.vat_person_correct_details?
          t.add_attribute(:vat_person_first_name, case_org)
          t.add_attribute(:vat_person_last_name, case_org)
          t.add_attribute(:vat_person_phone, case_org)
          t.add_attribute(:vat_person_address, case_org, text: format_address(case_org.vat_person_address))
        else
          t.add_attribute(:vat_alt_person_first_name, case_org)
          t.add_attribute(:vat_alt_person_last_name, case_org)
          t.add_attribute(:vat_alt_person_phone, case_org)
          t.add_attribute(:vat_alt_person_address, case_org, text: format_address(case_org.vat_alt_person_address))
        end

        t.add_attribute(:vat_certificate_declared, case_org, text: case_org.vat_certificate_declared ? I18n.t("generic.yes") : I18n.t("generic.no"))
      end
    end
  end

  def billing_preferences
    status = if case_org.billing_payment_method && case_org.billing_payment_terms && case_org.billing_invoicing_method && case_org.billing_payment_method
               :complete
             else
               :not_started
             end
    path = energy_case_org_billing_preferences_path(case_org.onboarding_case, case_org, context => "1")
    Task.new(title: __method__, status:, path:).tap do |t|
      t.add_attribute(:billing_payment_method, case_org, text: I18n.t("energy.check_your_answers.billing_preferences.#{case_org.billing_payment_method}"))
      t.add_attribute(:billing_payment_terms, case_org, text: I18n.t("energy.check_your_answers.billing_preferences.#{case_org.billing_payment_terms}"))
      t.add_attribute(:billing_invoicing_method, case_org)

      if case_org.billing_invoicing_method == "email"
        t.add_attribute(:billing_invoicing_email, case_org)
      else
        t.add_attribute(:billing_invoice_address, case_org, text: format_address(case_org.billing_invoice_address))
      end
    end
  end

  def case_org
    @case_org ||= Energy::OnboardingCaseOrganisation.includes(:gas_meters, :electricity_meters)
                                                    .find_by(energy_onboarding_case_id: @energy_onboarding_case_id)
  end

  def gas_single?
    case_org.gas_single_multi_single?
  end

  def gas_multi?
    case_org.gas_single_multi_multi?
  end

  def any_gas_meters?
    case_org.gas_meters.any?
  end

  def no_gas_meters?
    case_org.gas_meters.none?
  end

  def elec_single?
    case_org.electricity_meter_type_single?
  end

  def elec_multi?
    case_org.electricity_meter_type_multi?
  end

  def any_elec_meters?
    case_org.electricity_meters.any?
  end

  def no_elec_meters?
    case_org.electricity_meters.none?
  end

  def context_tasks?
    context == :tasks
  end

  class Task
    attr_accessor :title, :status, :path, :summary

    def initialize(title:, status: :not_started, path: "")
      @title = title
      @status = status
      @path = path
      @summary = []
    end

    def status_colour
      case status
      when :complete
        "green"
      when :in_progress
        "blue"
      when :not_started
        "grey"
      else
        "grey"
      end
    end

    def add_attribute(key, object, text: nil)
      @summary << [key, object.send(key), text].compact
    end
  end
end
