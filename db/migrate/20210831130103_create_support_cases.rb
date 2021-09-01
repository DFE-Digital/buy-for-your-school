class CreateSupportCases < ActiveRecord::Migration[6.1]
  def change
    create_table :support_cases, id: :uuid do |t|
      t.string :ref
      t.uuid :category_id
      t.string :sub_category_string
      t.string :request_text
      t.integer :support_level
      t.integer :status
      t.integer :state
      t.timestamps

      t.index :ref
      t.index :category_id
      t.index :support_level
      t.index :status
      t.index :state
    end
  end
end
