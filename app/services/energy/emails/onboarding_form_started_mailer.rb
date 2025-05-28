module Energy
  class Emails::OnboardingFormStartedMailer
    FORM_STARTED_EMAIL_TEMPLATE = "Email notification of Energy for Schools form started".freeze

    def initialize(onboarding_case_organisation:, to_recipients:, default_email_template:, onboarding_case_link:)
      @onboarding_case_organisation = onboarding_case_organisation
      @current_support_case = @onboarding_case_organisation.onboarding_case.support_case
      @to_recipients = to_recipients
      @default_email_template = default_email_template
      @onboarding_case_link = onboarding_case_link
    end

    def call
      draft = Email::Draft.new(
        default_content: @default_email_template,
        default_subject: default_email_subject,
        template_id: email_template&.id,
        ticket: @current_support_case.to_model,
        to_recipients: @to_recipients.to_json,
      ).save_draft!

      @energy_onboarding_email = Email::Draft.find(draft.id)
      @energy_onboarding_email.attributes = { html_content: email_template.body } if email_template

      parse_template

      @energy_onboarding_email.save_draft!
      @energy_onboarding_email.deliver_as_new_message
    end

  private

    def default_email_subject = "Case #{@current_support_case.ref} - form started: Energy for Schools"

    def email_template
      @email_template ||= Support::EmailTemplate.find_by(title: FORM_STARTED_EMAIL_TEMPLATE)
    end

    def parse_template
      @energy_onboarding_email.html_content = Energy::Emails::SchoolOnboardingVariableParser.new(@current_support_case, @energy_onboarding_email, @onboarding_case_link).parse_template
    end
  end
end
