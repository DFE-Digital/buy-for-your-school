class CreateSections < ActiveRecord::Migration[6.1]
  def change
    create_table :sections, id: :uuid do |t|
      t.references :journey, type: :uuid
      t.string :title, null: false
      t.timestamps
    end
  end
end
