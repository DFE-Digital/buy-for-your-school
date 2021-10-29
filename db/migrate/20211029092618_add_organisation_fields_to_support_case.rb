class AddOrganisationFieldsToSupportCase < ActiveRecord::Migration[6.1]
  def change
    change_table :support_cases, bulk: true do |t|
      t.column :organisation_name, :string
      t.column :organisation_urn, :string
    end
  end
end
