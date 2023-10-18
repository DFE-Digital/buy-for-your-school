class CacheMessagesJob < ApplicationJob
  queue_as :caching

  def perform
    Email.cache_messages_in_folder("Inbox")
    Email.cache_messages_in_folder("SentItems")
  end
end
