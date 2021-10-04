class AddSubmittedToSupportRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :support_requests, :submitted, :boolean, null: false, default: false
  end
end
