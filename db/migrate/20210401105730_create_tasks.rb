class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks, id: :uuid do |t|
      t.references :section, type: :uuid
      t.string :title, null: false
      t.string :contentful_id, null: false
      t.timestamps
    end
  end
end
