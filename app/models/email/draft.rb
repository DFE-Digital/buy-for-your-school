class Email::Draft
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes

  attribute :email
  attribute :mailbox, default: -> { Email.default_mailbox }
  attribute :microsoft_graph, default: -> { MicrosoftGraph.client }
  attribute :reply_to_email
  attribute :ticket
  attribute :template_id
  attribute :template_parser, default: -> { Email::TemplateParser.new }

  attribute :default_subject
  attribute :subject
  attribute :to_recipients, :json_array, default: -> { "[]" }
  attribute :cc_recipients, :json_array, default: -> { "[]" }
  attribute :bcc_recipients, :json_array, default: -> { "[]" }
  attribute :default_content
  attribute :html_content

  validates :html_content, presence: { message: "The email body cannot be blank" }
  validates :subject, presence: { message: "The subject cannot be blank" }, on: :new_message
  validates :to_recipients, email_recipients: { at_least_one: true, message: "The TO recipients contains an invalid email address" }, on: :new_message
  validates :cc_recipients, email_recipients: { message: "The CC recipients contains an invalid email address" }, on: :new_message
  validates :bcc_recipients, email_recipients: { message: "The BCC recipients contain an invalid email address" }, on: :new_message

  def self.find(id)
    email = Email.where(id:, is_draft: true).first
    return if email.nil?

    new(
      email:,
      html_content: email.body,
      subject: email.subject,
      to_recipients: email.to_recipients.to_json,
      cc_recipients: email.cc_recipients.to_json,
      bcc_recipients: email.bcc_recipients.to_json,
      template_id: email.template_id,
      ticket: email.ticket,
    )
  end

  def deliver_as_new_message
    email.cache_message(microsoft_graph.create_and_send_new_message(mailbox:, draft: self), folder: "SentItems")
  end

  def delivery_as_reply
    email.cache_message(microsoft_graph.create_and_send_new_reply(mailbox:, draft: self), folder: "SentItems")
  end

  def save_draft!
    if email.present?
      email.update!(
        subject:,
        body:,
        to_recipients:,
        cc_recipients:,
        bcc_recipients:,
      )
    else
      self.email =
        Email.create!(
          subject:,
          body:,
          to_recipients:,
          cc_recipients:,
          bcc_recipients:,
          template_id:,
          ticket:,
          is_draft: true,
          attachments: template_attachments,
        )
    end
  end

  def body
    template_parser.parse(html_content || template_body || default_content)
  end

  def subject
    template_parser.parse(super || template_subject || default_subject)
  end

  def attachments
    return [] if email.blank?

    email.attachments.map { |attachment| Attachable.from_blob(attachment.file.blob) }
  end

  def template
    Support::EmailTemplate.find(template_id) if template_id.present?
  end

  def reply_to_id
    reply_to_email.outlook_id
  end

private

  def template_subject
    "#{ticket.email_prefix} - #{template.subject}" if template.try(:subject).present?
  end

  def template_body
    template.try(:body)
  end

  def template_attachments
    return [] if template.blank?

    template.attachments.map do |attachment|
      blob = attachment.file.blob
      email_attachment = EmailAttachment.new(
        file_name: blob.filename,
        file_type: blob.content_type,
        file_size: blob.byte_size,
      )
      email_attachment.file.attach(
        io: StringIO.new(blob.download),
        filename: blob.filename,
        content_type: blob.content_type,
      )
      email_attachment
    end
  end
end
