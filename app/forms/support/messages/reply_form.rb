module Support
  class Messages::ReplyForm < Form
    extend Dry::Initializer
    include Concerns::ValidatableForm

    attr_reader :template

    option :body, Types::Params::String, optional: true
    option :to_recipients, Types::JSONArrayField, optional: true
    option :cc_recipients, Types::JSONArrayField, optional: true
    option :bcc_recipients, Types::JSONArrayField, optional: true
    option :subject, Types::Params::String, optional: true
    option :file_attachments, optional: true, default: proc { [] }
    option :blob_attachments, optional: true
    option :template_id, optional: true
    option :default_template, optional: true
    option :default_subject, optional: true
    option :parser, optional: true
    option :case_ref, optional: true

    def initialize(**args)
      super(**args)
      @template = get_template
      @body = body || parser.parse(get_body)
      @subject = subject || get_subject
      @blob_attachments = blob_attachments.present? ? Support::Emails::Attachments.resolve_blob_attachments(JSON.parse(blob_attachments)) : []
    end

    def reply_to_email(email, kase, agent)
      reply_options = {
        reply_to_email: email,
        reply_text: body,
        sender: agent,
        file_attachments: outlook_file_attachments,
        template_id:,
      }

      ::Messages::ReplyToMessage.new.call(support_case_id: kase.id, reply_options:)
    end

    def create_new_message(kase, agent)
      message_options = {
        to_recipients:,
        cc_recipients:,
        bcc_recipients:,
        message_text: body,
        sender: agent,
        file_attachments: outlook_file_attachments,
        subject:,
        template_id:,
      }

      ::Messages::SendNewMessage.new.call(support_case_id: kase.id, message_options:)
    end

  private

    def outlook_file_attachments
      all_attachments = @file_attachments + @blob_attachments.map { |attachment| attachment.file.blob }
      all_attachments.map { |attachment| Support::Messages::Outlook::Reply::Attachment.create(attachment) }
    end

    def get_body
      return default_template if @template.blank?

      @template.body
    end

    def get_subject
      return default_subject if @template.blank?

      if @template.subject.present?
        "Case #{case_ref} - #{@template.subject}"
      else
        default_subject
      end
    end

    def get_template = template_id.present? ? Support::EmailTemplate.find(template_id) : nil
  end
end
