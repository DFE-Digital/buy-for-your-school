class AddOrgToSupportCase < ActiveRecord::Migration[6.1]
  def change
    add_column :support_cases, :organisation_id, :uuid, index: true
  end
end
