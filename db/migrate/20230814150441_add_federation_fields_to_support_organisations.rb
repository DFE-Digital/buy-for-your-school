class AddFederationFieldsToSupportOrganisations < ActiveRecord::Migration[7.0]
  def change
    change_table :support_organisations, bulk: true do |t|
      t.column :federation_name, :string
      t.column :federation_code, :string
    end
  end
end
