class CreateSupportProcurementStages < ActiveRecord::Migration[7.0]
  def change
    create_table :support_procurement_stages, id: :uuid do |t|
      t.string :title, null: false
      t.string :key, null: false, index: { unique: true }
      t.integer :stage, null: false
      t.boolean :archived, default: false, null: false

      t.timestamps
    end
  end
end
