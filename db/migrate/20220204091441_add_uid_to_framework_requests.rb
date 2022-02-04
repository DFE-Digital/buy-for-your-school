class AddUidToFrameworkRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :framework_requests, :uid, :string
  end
end
