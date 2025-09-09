module Energy
  class Emails::BaseMailer
    def initialize(onboarding_case:, to_recipients:)
      @onboarding_case = onboarding_case
      @onboarding_case_organisation = @onboarding_case.onboarding_case_organisations.first
      @support_case = @onboarding_case.support_case
      @to_recipients = to_recipients
    end

    def call
      draft = Email::Draft.new(
        default_content: default_email_template,
        default_subject: default_email_subject,
        template_id: email_template&.id,
        ticket: @support_case.to_model,
        to_recipients: @to_recipients.to_json,
      ).save_draft!

      @email_draft = Email::Draft.find(draft.id)
      @email_draft.attributes = { html_content: email_template.body } if email_template

      parse_template

      @email_draft.save_draft!
      @email_draft.deliver_as_new_message
    end
  end
end
