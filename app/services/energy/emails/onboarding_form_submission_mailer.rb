module Energy
  class Emails::OnboardingFormSubmissionMailer
    FORM_SUBMISSION_EMAIL_TEMPLATE = "Email notification of Energy for Schools form completed".freeze

    def initialize(onboarding_case_organisation:, to_recipients:, default_email_template:)
      @onboarding_case_organisation = onboarding_case_organisation
      @current_support_case = @onboarding_case_organisation.onboarding_case.support_case
      @to_recipients = to_recipients
      @default_email_template = default_email_template
    end

    def call
      draft = Email::Draft.new(
        default_content: @default_email_template,
        default_subject: default_email_subject,
        template_id: email_template&.id,
        ticket: @current_support_case.to_model,
        to_recipients: @to_recipients.to_json,
      ).save_draft!

      @email_draft = Email::Draft.find(draft.id)
      @email_draft.attributes = { html_content: email_template.body } if email_template

      parse_template

      @email_draft.save_draft!
      @email_draft.deliver_as_new_message
    end

  private

    def default_email_subject = "Case #{@current_support_case.ref} - form submission: Energy for Schools"

    def email_template
      @email_template ||= Support::EmailTemplate.find_by(title: FORM_SUBMISSION_EMAIL_TEMPLATE)
    end

    def parse_template
      @email_draft.html_content = Energy::Emails::OnboardingFormSubmissionVariableParser.new(@current_support_case, @onboarding_case_organisation, @email_draft).parse_template
    end
  end
end
