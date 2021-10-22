class CreateSupportGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :support_groups, id: :uuid do |t|
      t.string :name, null: false, index: { unique: true }
      t.integer :code, null: false, index: { unique: true }
      t.integer :establishment_types_count, default: 0

      t.timestamps
    end
  end
end
