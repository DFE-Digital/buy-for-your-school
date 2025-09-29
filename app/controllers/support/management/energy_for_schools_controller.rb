module Support
  class Management::EnergyForSchoolsController < ::Support::Management::BaseController
    def index
      @email_template_config = Energy::EmailTemplateConfiguration.all

      @electricity_supplier_email = fetch_email_ids(:electricity, :electricity_supplier_email)
      @electricity_supplier_submitted_template = fetch_template_name(:electricity, :electricity_supplier_submitted_template)
      @electricity_supplier_direct_debit_template = fetch_template_name(:electricity, :electricity_supplier_direct_debit_template)
      @electricity_supplier_vat_template = fetch_template_name(:electricity, :electricity_supplier_vat_template)
      @electricity_supplier_direct_debit_vat_template = fetch_template_name(:electricity, :electricity_supplier_direct_debit_vat_template)

      @gas_supplier_email = fetch_email_ids(:gas, :gas_supplier_email)
      @gas_supplier_submitted_template = fetch_template_name(:gas, :gas_supplier_submitted_template)
      @gas_supplier_direct_debit_template = fetch_template_name(:gas, :gas_supplier_direct_debit_template)
      @gas_supplier_vat_template = fetch_template_name(:gas, :gas_supplier_vat_template)
      @gas_supplier_direct_debit_vat_template = fetch_template_name(:gas, :gas_supplier_direct_debit_vat_template)

      @school_electricity_direct_debit_template = fetch_template_name(:electricity, :school_electricity_direct_debit_template)
      @school_gas_direct_debit_template = fetch_template_name(:gas, :school_gas_direct_debit_template)
      @school_electricity_vat_template = fetch_template_name(:electricity, :school_electricity_vat_template)
      @school_gas_vat_template = fetch_template_name(:gas, :school_gas_vat_template)
      @school_electricity_direct_debit_vat_template = fetch_template_name(:electricity, :school_electricity_direct_debit_vat_template)
      @school_gas_direct_debit_vat_template = fetch_template_name(:gas, :school_gas_direct_debit_vat_template)
    end

  private

    def fetch_email_ids(energy_type, configure_option)
      config = @email_template_config.where(energy_type:, configure_option:).first
      config ? config.to_email_ids : I18n.t("support.management.energy_for_schools.not_provided")
    end

    def fetch_template_name(energy_type, configure_option)
      @email_template_config.where(energy_type:, configure_option:).first&.template_name || I18n.t("support.management.energy_for_schools.not_provided")
    end

    def redirect_path
      is_user_cec_agent? ? cec_management_agents_path : support_management_agents_path
    end

    helper_method def is_user_cec_agent?
      (current_agent.roles & %w[cec cec_admin]).any?
    end

    helper_method def portal_management_energy_for_schools_path
      send("#{portal_namespace}_management_energy_for_schools_path")
    end

    helper_method def portal_management_path
      send("#{portal_namespace}_management_path")
    end

    def authorize_agent_scope = [super, :manage_agents?]
  end
end
