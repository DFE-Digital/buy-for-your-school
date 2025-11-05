module Energy
  class Emails::BaseMailer
    def initialize(onboarding_case:, to_recipients:, documents: [])
      @onboarding_case = onboarding_case
      @onboarding_case_organisation = @onboarding_case.onboarding_case_organisations.first
      @support_case = @onboarding_case.support_case
      @to_recipients = to_recipients
      @documents = documents
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
      attach_documents if @documents.any?

      @email_draft.save_draft!
      @email_draft.deliver_as_new_message
    end

  private

    def attach_documents
      @documents.each do |document|
        @email_draft.email.attachments.create!(file: document)
      end
    rescue StandardError => e
      Rails.logger.error("Error attaching documents: #{e.message}")
      raise e
    end
  end
end
