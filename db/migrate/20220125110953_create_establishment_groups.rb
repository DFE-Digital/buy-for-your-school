class CreateEstablishmentGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :support_establishment_groups, id: :uuid do |t|
      t.string :name, null: false, index: true
      t.string :ukprn, index: true
      t.string :uid, index: { unique: true }
      t.integer :status, null: false
      t.jsonb :address
      t.references :establishment_group_type, type: :uuid, index: { name: :index_establishment_groups_on_establishment_group_type_id }

      t.timestamps
    end
  end
end
