class Email::Sendable::MsGraphDelivery
  DEFAULT_HEADERS = { "Prefer" => 'IdType="ImmutableId"' }.freeze

  attr_reader :mailbox, :microsoft_graph

  def initialize(mailbox: Email.default_mailbox, microsoft_graph: MicrosoftGraph.client)
    @mailbox = mailbox
    @microsoft_graph = microsoft_graph
  end

  def deliver_as_new_message(draft)
    message_id = microsoft_graph.create_message(user_id:, http_headers: DEFAULT_HEADERS)

    add_content_and_send(draft, message_id:, details: details_for_new_message(draft))
  end

  def deliver_as_reply(draft)
    draft_message = microsoft_graph.create_reply_all_message(user_id:, reply_to_id: draft.reply_to_email.outlook_id, http_headers: DEFAULT_HEADERS)

    add_content_and_send(draft, message_id: draft_message.id, details: details_for_reply(draft, draft_message))
  end

private

  def add_content_and_send(draft, message_id:, details:)
    microsoft_graph.update_message(user_id:, message_id:, details:)

    draft.attachments.each do |file_attachment|
      microsoft_graph.add_file_attachment_to_message(user_id:, file_attachment:, message_id:)
    end

    microsoft_graph.send_message(user_id:, message_id:)
    microsoft_graph.get_message(user_id:, message_id:)
  end

  def details_for_new_message(draft)
    email_addresses = lambda do |recipients|
      recipients.map { |email| { "emailAddress" => { "address" => email } } }
    end

    {
      subject: draft.subject,
      body: {
        "ContentType" => "HTML",
        "content" => draft.body,
      },
      from: {
        "emailAddress": {
          "name" => mailbox.name,
          "address" => mailbox.email_address,
        },
      },
      toRecipients: email_addresses[draft.to_recipients],
      ccRecipients: email_addresses[draft.cc_recipients],
      bccRecipients: email_addresses[draft.bcc_recipients],
    }
  end

  def details_for_reply(draft, draft_message)
    {
      body: {
        "ContentType" => "HTML",
        # draft_message.body contains the previous email chain we need to preserve in new message
        # for it to appear under a "fold" in the email client
        "content" => "<html><body>#{draft.body}</body></html>#{draft_message.body.content}",
      },
    }
  end

  def user_id = mailbox.user_id
end
