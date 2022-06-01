class CreateSupportQueries < ActiveRecord::Migration[6.1]
  def change
    create_table :support_queries, id: :uuid do |t|
      t.string :title, null: false

      t.timestamps
    end
  end
end
