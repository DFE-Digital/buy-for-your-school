class ResyncCachedMessagesOutlookIdsJob < ApplicationJob
  queue_as :caching

  def perform
    Email.resync_outlook_ids_of_moved_messages
  end
end
