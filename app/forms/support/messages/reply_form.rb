module Support
  class Messages::ReplyForm < Form
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :body, Types::Params::String, optional: true
    option :to_recipients, Types::JSONArrayField, optional: true
    option :cc_recipients, Types::JSONArrayField, optional: true
    option :bcc_recipients, Types::JSONArrayField, optional: true
    option :subject, Types::Params::String, optional: true
    option :attachments, optional: true

    def reply_to_email(email, agent)
      reply = Support::Messages::Outlook::SendReplyToEmail.new(
        reply_to_email: email,
        reply_text: body,
        sender: agent,
        file_attachments:,
      )

      reply.call
    end

    def create_new_message(agent)
      message = Support::Messages::Outlook::SendNewMessage.new(
        to_recipients:,
        cc_recipients:,
        bcc_recipients:,
        message_text: body,
        sender: agent,
        file_attachments:,
        subject:,
      )

      message.call
    end

  private

    def file_attachments
      Array(attachments).map { |uploaded_file| Support::Messages::Outlook::Reply::FileAttachment.from_uploaded_file(uploaded_file) }
    end
  end
end
