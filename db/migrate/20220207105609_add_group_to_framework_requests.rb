class AddGroupToFrameworkRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :framework_requests, :group, :boolean
  end
end
