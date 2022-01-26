class CreateEstablishmentGroupTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :support_establishment_group_types, id: :uuid do |t|
      t.string :name, null: false, index: { unique: true }
      t.integer :code, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
