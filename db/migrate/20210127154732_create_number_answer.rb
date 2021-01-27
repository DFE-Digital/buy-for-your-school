class CreateNumberAnswer < ActiveRecord::Migration[6.1]
  def up
    create_table :number_answers, id: :uuid do |t|
      t.references :step, type: :uuid
      t.integer :response, null: false
      t.timestamps
    end
  end

  def down
    drop_table :number_answers
  end
end
