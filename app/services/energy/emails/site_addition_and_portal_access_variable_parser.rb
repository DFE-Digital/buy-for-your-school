module Energy
  class Emails::SiteAdditionAndPortalAccessVariableParser
    include Energy::SwitchingEnergyTypeHelper
    include ActionView::Helpers::UrlHelper

    def initialize(current_case, onboarding_case_organisation, email_draft)
      @current_case = current_case
      @onboarding_case_organisation = onboarding_case_organisation
      @email_draft = email_draft
    end

    def parse_template
      Liquid::Template.parse(@email_draft.body, error_mode: :strict).render(variables)
    end

  private

    def variables
      {
        "case_creator_full_name" => "#{@current_case.first_name} #{@current_case.last_name}".strip,
        "case_reference_number" => @current_case.ref,
        "organisation_name" => @current_case.organisation_name || @current_case.email,
        "gas_contract_start_date" => start_date(@onboarding_case_organisation.gas_current_contract_end_date),
        "electricity_contract_start_date" => start_date(@onboarding_case_organisation.electric_current_contract_end_date),
      }
    end

    def start_date(contract_end_date)
      return unless contract_end_date.is_a?(Date)

      (contract_end_date + 1.day).to_date.strftime("%d %B %Y")
    end
  end
end
