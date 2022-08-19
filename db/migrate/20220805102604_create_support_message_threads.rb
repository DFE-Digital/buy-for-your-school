class CreateSupportMessageThreads < ActiveRecord::Migration[7.0]
  def change
    create_view :support_message_threads
  end
end
