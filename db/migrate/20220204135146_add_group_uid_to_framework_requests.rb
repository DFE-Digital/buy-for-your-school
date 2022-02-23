class AddGroupUidToFrameworkRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :framework_requests, :group_uid, :string
  end
end
