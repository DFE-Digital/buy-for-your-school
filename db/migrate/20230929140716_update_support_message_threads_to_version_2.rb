class UpdateSupportMessageThreadsToVersion2 < ActiveRecord::Migration[7.0]
  def change
  
    update_view :support_message_threads, version: 2, revert_to_version: 1
  end
end
