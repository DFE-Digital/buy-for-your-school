module Energy
  class Emails::OnboardingFormDdEdfMailer < Energy::Emails::BaseMailer
    FORM_DD_EDF_EMAIL_TEMPLATE = "Energy for Schools: electricity Direct Debit".freeze

    def default_template
      ApplicationController.renderer.render(
        partial: "energy/letter_of_authorisations/onboarding_form_dd_edf_email_template",
      )
    end

  private

    def default_email_subject = "Case #{@support_case.ref} - set up your Direct Debit for electricity: Energy for Schools"

    def email_template
      @email_template ||= Support::EmailTemplate.find_by(title: FORM_DD_EDF_EMAIL_TEMPLATE, archived: false)
    end

    def default_email_template
      ApplicationController.renderer.render(
        partial: "energy/letter_of_authorisations/onboarding_form_dd_edf_email_template",
      )
    end

    def parse_template
      @email_draft.html_content = Energy::Emails::OnboardingFormDdEdfVariableParser.new(@support_case, @onboarding_case_organisation, @email_draft).parse_template
    end
  end
end
