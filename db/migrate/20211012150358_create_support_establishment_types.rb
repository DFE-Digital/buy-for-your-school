class CreateSupportEstablishmentTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :support_establishment_types, id: :uuid do |t|
      t.uuid :group_id, null: false
      t.string :name, null: false, index: { unique: true }
      t.integer :code, null: false, index: { unique: true }
      t.integer :organisations_count, default: 0

      t.timestamps
    end
  end
end
