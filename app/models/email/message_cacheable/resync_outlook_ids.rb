class Email::MessageCacheable::ResyncOutlookIds
  REPLY_TO_ID = MicrosoftGraph::Resource::SingleValueExtendedProperty::ID_PR_IN_REPLY_TO_ID

  attr_reader :message

  def initialize(message)
    @message = message
  end

  def call
    return unless email_in_need_of_resync?

    email.update!(
      outlook_internet_message_id:,
      outlook_id:,
      outlook_conversation_id:,
      in_reply_to_id:,
    )
  end

  def email
    Email.find_by(outlook_internet_message_id:) || Email.find_by(subject:, sent_at:)
  end

private

  def email_in_need_of_resync?
    email.present? && (
      email.outlook_id != message["id"] ||
      email.outlook_internet_message_id.nil? ||
      email.outlook_conversation_id.nil? ||
      (email.in_reply_to_id.nil? && in_reply_to_id.present?)
    )
  end

  def outlook_internet_message_id = message["internetMessageId"]
  def outlook_id = message["id"]
  def outlook_conversation_id = message["conversationId"]
  def subject = message["subject"]
  def sent_at = message["sentDateTime"]

  def in_reply_to_id
    Array(message["singleValueExtendedProperties"])
      .select { |svep| svep["id"] == REPLY_TO_ID }
      .map    { |svep| svep["value"] }
      .first
  end
end
