class Email::Draft
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes

  attribute :mailbox, default: -> { Email.default_mailbox }
  attribute :microsoft_graph, default: -> { MicrosoftGraph.client }
  attribute :reply_to_email
  attribute :ticket
  attribute :template_id
  attribute :template_parser, default: -> { Email::TemplateParser.new }

  attribute :default_subject
  attribute :subject
  attribute :to_recipients, default: -> { [] }
  attribute :cc_recipients, default: -> { [] }
  attribute :bcc_recipients, default: -> { [] }
  attribute :default_content
  attribute :html_content
  attribute :file_attachments, default: -> { [] }
  attribute :blob_attachments, default: -> { "[]" }

  validates :html_content, presence: { message: "The email body cannot be blank" }
  validates :subject, presence: { message: "The subject cannot be blank" }, on: :new_message
  validates :to_recipients, email_recipients: { at_least_one: true, message: "The TO recipients contains an invalid email address" }, on: :new_message
  validates :cc_recipients, email_recipients: { message: "The CC recipients contains an invalid email address" }, on: :new_message
  validates :bcc_recipients, email_recipients: { message: "The BCC recipients contain an invalid email address" }, on: :new_message
  validates :file_attachments, email_attachments: true

  def deliver_as_new_message
    cache_message microsoft_graph.create_and_send_new_message(mailbox:, draft: self)
  end

  def delivery_as_reply
    cache_message microsoft_graph.create_and_send_new_reply(mailbox:, draft: self)
  end

  def body
    template_parser.parse(html_content || template_body || default_content)
  end

  def subject
    template_parser.parse(super || template_subject || default_subject)
  end

  def attachments
    (file_attachments + template_attachments).map(&Attachable.method(:get))
  end

  def template
    Support::EmailTemplate.find(template_id) if template_id.present?
  end

private

  def template_subject
    "#{ticket.email_prefix} - #{template.subject}" if template.try(:subject).present?
  end

  def template_body
    template.try(:body)
  end

  def template_attachments
    Support::EmailTemplateAttachment.find(Array(JSON.parse(blob_attachments)).pluck("file_id"))
  end

  def cache_message(message)
    email = Email.cache_message(message, folder: "SentItems", ticket:)
    email.update!(template_id:)
  end
end
