class AddExtraGiasFieldsToOrganisations < ActiveRecord::Migration[6.1]
  def change
    change_table :support_organisations, bulk: true do |t|
      t.column :ukprn, :string
      t.column :telephone_number, :string
      t.column :local_authority, :jsonb
      t.column :open_date, :datetime
      t.column :number, :string
      t.column :rsc_region, :string
    end
  end
end
