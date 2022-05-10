module Support
  class Messages::ReplyFormSchema < ::Support::Schema
    config.messages.top_namespace = :message_reply_form

    params do
      required(:body).value(:string)
      optional(:attachments)
    end

    rule(:body) do
      key(:body).failure(:missing) if value.blank?
    end

    rule(:attachments) do
      if value.present?
        # check for viruses!
      end
    end
  end
end
