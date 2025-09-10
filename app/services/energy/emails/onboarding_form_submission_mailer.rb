module Energy
  class Emails::OnboardingFormSubmissionMailer < Energy::Emails::BaseMailer
    FORM_SUBMISSION_EMAIL_TEMPLATE = "Email notification of Energy for Schools form completed".freeze

    def default_template
      ApplicationController.renderer.render(
        partial: "energy/letter_of_authorisations/onboarding_form_submission_email_template",
      )
    end

  private

    def default_email_subject = "Case #{@support_case.ref} - form submission: Energy for Schools"

    def email_template
      @email_template ||= Support::EmailTemplate.find_by(title: FORM_SUBMISSION_EMAIL_TEMPLATE, archived: false)
    end

    def default_email_template
      ApplicationController.renderer.render(
        partial: "energy/letter_of_authorisations/onboarding_form_submission_email_template",
      )
    end

    def parse_template
      @email_draft.html_content = Energy::Emails::OnboardingFormSubmissionVariableParser.new(@support_case, @onboarding_case_organisation, @email_draft).parse_template
    end
  end
end
