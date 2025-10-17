module Energy
  class Emails::OnboardingFormSubmissionMailer < Energy::Emails::BaseMailer
    FORM_SUBMISSION_EMAIL_TEMPLATE = "Email notification of Energy for Schools form completed".freeze
    FORM_SUBMISSION_EMAIL_TEMPLATE_NEW = "AUTO usage: Email notification of Energy for Schools form completed".freeze

  private

    def default_email_subject = "Case #{@support_case.ref} - form submission: Energy for Schools"

    def email_template
      cms_template = Flipper.enabled?(:auto_email_vat_dd) ? FORM_SUBMISSION_EMAIL_TEMPLATE_NEW : FORM_SUBMISSION_EMAIL_TEMPLATE
      @email_template ||= Support::EmailTemplate.find_by(title: cms_template, archived: false)
    end

    def default_email_template
      ruby_template = if Flipper.enabled?(:auto_email_vat_dd)
                        "energy/letter_of_authorisations/onboarding_form_submission_email_template_new"
                      else
                        "energy/letter_of_authorisations/onboarding_form_submission_email_template"
                      end

      ApplicationController.renderer.render(partial: ruby_template)
    end

    def parse_template
      @email_draft.html_content = Energy::Emails::OnboardingFormSubmissionVariableParser.new(@support_case, @onboarding_case_organisation, @email_draft).parse_template
    end
  end
end
