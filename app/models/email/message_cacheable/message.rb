class Email::MessageCacheable::Message < SimpleDelegator
  def as_email
    {
      outlook_id: id,
      sender:,
      recipients:,
      subject:,
      body: body.content,
      unique_body: unique_body&.content,
      sent_at: sent_date_time,
      outlook_conversation_id: conversation_id,
      outlook_received_at: received_date_time,
      outlook_has_attachments: has_attachments,
      outlook_is_read: is_read,
      outlook_is_draft: is_draft,
      in_reply_to_id:,
      to_recipients:,
      cc_recipients:,
      bcc_recipients:,
    }
  end

  def sender
    { address: from.email_address.address, name: from.email_address.name }
  end

  def recipients = to_recipients + cc_recipients + bcc_recipients

  def to_recipients = map_recipients(super)

  def cc_recipients = map_recipients(super)

  def bcc_recipients = map_recipients(super)

private

  def map_recipients(recipients_to_map)
    recipients_to_map.map(&:email_address).map do |email_address|
      { address: email_address.address, name: email_address.name }
    end
  end
end
