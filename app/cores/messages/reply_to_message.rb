module Messages
  class ReplyToMessage
    include Wisper::Publisher

    def call(support_case_id:, reply_options:)
      Support::Messages::Outlook::SendReplyToEmail.new(**reply_options).call

      broadcast(:contact_to_school_made, { support_case_id:, contact_type: "replying to a message" })
    end
  end
end
