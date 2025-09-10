module Energy
  class Emails::DirectDebitVatEdfVariableParser
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
        "billing_payment_terms" => I18n.t("energy.check_your_answers.billing_preferences.#{@onboarding_case_organisation.billing_payment_terms}"),
        "electricity_contract_end_date" => set_end_date(@onboarding_case_organisation.electric_current_contract_end_date),
      }
    end

    def set_end_date(contract_end_date)
      return unless contract_end_date.is_a?(Date)

      (contract_end_date + 1.day).to_date.strftime("%d/%m/%Y")
    end
  end
end
