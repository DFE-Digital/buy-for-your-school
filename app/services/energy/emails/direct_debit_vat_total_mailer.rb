module Energy
  class Emails::DirectDebitVatTotalMailer
    DD_VAT_TOTAL_EMAIL_TEMPLATE = "Energy for Schools: gas VAT and DD instructions".freeze

    def initialize(onboarding_case:, to_recipients:, documents: [])
      @onboarding_case = onboarding_case
      @onboarding_case_organisation = @onboarding_case.onboarding_case_organisations.first
      @support_case = @onboarding_case.support_case
      @to_recipients = to_recipients
      @documents = documents
    end

    def default_template
      ApplicationController.renderer.render(
        partial: "energy/letter_of_authorisations/direct_debit_vat_total_email_template",
      )
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

    def default_email_subject = "Case #{@support_case.ref} - send your VAT and Direct Debit instructions for gas: Energy for Schools"

    def email_template
      @email_template ||= Support::EmailTemplate.find_by(title: DD_VAT_TOTAL_EMAIL_TEMPLATE, archived: false)
    end

    def default_email_template
      ApplicationController.renderer.render(
        partial: "energy/letter_of_authorisations/direct_debit_vat_total_email_template",
      )
    end

    def parse_template
      @email_draft.html_content = Energy::Emails::DirectDebitVatTotalVariableParser.new(@support_case, @onboarding_case_organisation, @email_draft).parse_template
    end

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
