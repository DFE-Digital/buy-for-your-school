class AddContactInvitedToSharepointToCases < ActiveRecord::Migration[7.1]
  def change
    add_column :support_cases, :contact_invited_to_sharepoint, :boolean
  end
end
