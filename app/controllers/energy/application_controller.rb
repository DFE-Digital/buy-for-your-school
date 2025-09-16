module Energy
  class ApplicationController < ::ApplicationController
    before_action :check_flag, :set_accessibility_link, :check_if_submitted, :set_routing_flags

    ALLOWED_CLASSES = [
      "Support::Organisation",
      "Support::EstablishmentGroup",
    ].freeze

    MAX_METER_COUNT = 5

  private

    def set_accessibility_link
      @energy_accessibility_link = "https://accessibility-statements.education.gov.uk/s/29"
    end

    def check_flag
      render "errors/not_found", status: :not_found unless Flipper.enabled?(:energy)
    end

    def check_if_submitted
      redirect_to energy_case_confirmation_path(onboarding_case) if onboarding_case.submitted?
    end

    def set_routing_flags
      @routing_flags = { tasks: params[:tasks], check: params[:check], vat_declaration_prompt: params[:vat_declaration_prompt] }
    end

    def from_check?
      params[:check] == "1"
    end

    def from_tasks?
      params[:tasks] == "1"
    end

    def from_vat_declaration_prompt?
      params[:vat_declaration_prompt] == "1"
    end

    def onboarding_case
      @onboarding_case ||= Energy::OnboardingCase.find(params[:case_id])
    end

    def organisation_details(id = params[:case_id])
      @onboarding_case_organisation = Energy::OnboardingCaseOrganisation.find_by(energy_onboarding_case_id: id)
      onboardable_type = @onboarding_case_organisation.onboardable_type

      if ALLOWED_CLASSES.include?(onboardable_type)
        @organisation_detail = onboardable_type.safe_constantize.find(@onboarding_case_organisation.onboardable_id)
        check_user_has_access_to_organisation(@organisation_detail)
      else
        render("errors/not_found", status: :not_found)
      end
    end

    def check_user_has_access_to_organisation(support_org)
      valid_orgs = current_user.orgs.pluck("urn", "uid").flatten.compact

      access_to_single_school = support_org.respond_to?(:urn) && valid_orgs.include?(support_org.urn)
      access_to_trust = support_org.respond_to?(:uid) && valid_orgs.include?(support_org.uid)
      access_to_school_in_trust = support_org.respond_to?(:trust_code) && valid_orgs.include?(support_org.trust_code)

      unless access_to_single_school || access_to_trust || access_to_school_in_trust
        render("errors/not_found", status: :not_found)
      end
    end

    def switching_electricity?
      @onboarding_case_organisation.switching_energy_type_electricity?
    end

    def switching_gas?
      @onboarding_case_organisation.switching_energy_type_gas?
    end

    def switching_both?
      @onboarding_case_organisation.switching_energy_type_gas_electricity?
    end

    def going_to_tasks?
      params[:commit] != I18n.t("generic.button.save_continue") && !params[:js_form_submit]
    end

    def gas_single_meter?
      @onboarding_case_organisation.gas_single_multi_single?
    end

    def gas_multiple_meters?
      @onboarding_case_organisation.gas_single_multi_multi?
    end

    def gas_meter_usage_exist?
      @onboarding_case_organisation.gas_meters.any?
    end

    def gas_meter_usage_details
      @onboarding_case_organisation.gas_meters.all
    end

    def electricity_multiple_meters?
      @onboarding_case_organisation.electricity_meter_type_multi?
    end

    def electricity_usage_exist?
      @onboarding_case_organisation.electricity_meters.any?
    end

    def electricity_usage_details
      @onboarding_case_organisation.electricity_meters.all
    end
  end
end
