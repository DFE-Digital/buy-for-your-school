class CreateSupportOrganisations < ActiveRecord::Migration[6.1]
  def change
    create_table :support_organisations, id: :uuid do |t|
      t.belongs_to :establishment_type, type: :uuid
      t.string :urn, null: false, index: { unique: true }
      t.string :name, null: false
      t.jsonb :address, null: false
      t.jsonb :contact, null: false

      t.integer :phase
      t.integer :gender
      t.integer :status

      t.timestamps
    end
  end
end
