module Email::MessageCacheable
  extend ActiveSupport::Concern

  FOLDER_MAP = {
    "Inbox" => :inbox,
    "SentItems" => :sent_items,
  }.freeze

  included do
    include MailboxConfigurable
    include Callbackable
  end

  def cache_message(message, folder:)
    email_details = Message.new(message).as_email
    update!(**email_details, folder: FOLDER_MAP[folder])
    if is_draft
      Email.on_new_message_cached_handlers.call(self)
      update!(is_draft: false)
    end
  end

  class_methods do
    def cache_messages_in_folder(folder, mailbox: default_mailbox, messages_after: 15.minutes.ago)
      messages = MicrosoftGraph.mail.list_messages_in_folder(mailbox.user_id, folder, messages_after:)
      messages.each { |message| cache_message(message, folder:) }
    end

    def cache_message(message, folder:, ticket: nil)
      email = find_or_initialize_by(outlook_internet_message_id: message.internet_message_id, folder: FOLDER_MAP[folder])

      email_details = Message.new(message).as_email
      email_details[:ticket] = ticket if ticket.present?
      email.update!(email_details)

      on_new_message_cached_handlers.call(email) if email.previously_new_record?

      email
    end

    def resync_outlook_ids_of_moved_messages(messages_updated_after: 15.minutes.ago)
      query = [
        "$filter=lastModifiedDateTime ge #{messages_updated_after.utc.iso8601}",
        "$select=internetMessageId,subject,sentDateTime,conversationId",
        "$orderby=lastModifiedDateTime asc",
        "$expand=singleValueExtendedProperties($filter=id eq '#{MicrosoftGraph::Resource::SingleValueExtendedProperty::ID_PR_IN_REPLY_TO_ID}')",
      ]

      recently_updated_messages = MicrosoftGraph.mail.list_messages(default_mailbox.user_id, query:)
      recently_updated_messages.each { |message| resync_outlook_ids_of_moved_message(message) }
    end

    def resync_outlook_ids_of_moved_message(message)
      ResyncOutlookIds.new(message).call
    end
  end
end
