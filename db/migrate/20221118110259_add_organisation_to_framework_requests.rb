class AddOrganisationToFrameworkRequests < ActiveRecord::Migration[7.0]
  def change
    change_table :framework_requests, bulk: true do |t|
      t.column :organisation_id, :uuid
      t.column :organisation_type, :string
    end
  end
end
