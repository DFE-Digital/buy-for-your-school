module Energy
  class Emails::OnboardingFormVatEdfVariableParser
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
        "case_creator_first_name" => @current_case.first_name,
      }
    end
  end
end
