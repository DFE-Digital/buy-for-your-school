module Energy
  class Emails::OnboardingFormSubmissionVariableParser
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
        "electricity_contract_start_date" => "SOME VALUES",
        "gas_and_or_electricity_contract_start_dates" => build_gas_and_or_electricity_contract_start_dates,
      }
    end

    def build_gas_and_or_electricity_contract_start_dates
      if switching_gas?
        gas = set_start_date(@onboarding_case_organisation.gas_current_contract_end_date)
        "<span>#{gas} (gas)</span>"
      elsif switching_electricity?
        electricity = set_start_date(@onboarding_case_organisation.electric_current_contract_end_date)
        "<span>#{electricity} (electricity)</span>"
      elsif switching_both?
        gas = set_start_date(@onboarding_case_organisation.gas_current_contract_end_date)
        electricity = set_start_date(@onboarding_case_organisation.electric_current_contract_end_date)
        "<span>#{gas} (gas)</span> </br> <span>#{electricity} (electricity)</span>"
      else
        ""
      end
    end

    def switching_gas?
      @onboarding_case_organisation.switching_energy_type_gas?
    end

    def switching_electricity?
      @onboarding_case_organisation.switching_energy_type_electricity?
    end

    def switching_both?
      @onboarding_case_organisation.switching_energy_type_gas_electricity?
    end

    def set_start_date(contract_end_date)
      (contract_end_date + 1.day).to_date.strftime("%d/%m/%y")
    end
  end
end
