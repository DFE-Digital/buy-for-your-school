module Support
  class Messages::ReplyForm < Form
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :body, Types::Params::String, optional: true
    option :attachments, optional: true

    def reply_to_email(email, agent)
      reply = Support::Messages::Outlook::SendReplyToEmail.new(
        reply_to_email: email,
        reply_text: body,
        sender: agent,
        file_attachments: file_attachments,
      )

      reply.call
    end

    def create_new_message(recipient, agent, case_reference)
      message = Support::Messages::Outlook::SendNewMessage.new(
        recipient: recipient,
        message_text: body,
        sender: agent,
        file_attachments: file_attachments,
        subject: "Case #{case_reference} – DfE Get help buying for schools: your request for advice and guidance",
      )

      message.call
    end

  private

    def file_attachments
      Array(attachments).map { |uploaded_file| Support::Messages::Outlook::Reply::FileAttachment.from_uploaded_file(uploaded_file) }
    end
  end
end
