class CreateShortTextAnswer < ActiveRecord::Migration[6.0]
  def up
    create_table :short_text_answers, id: :uuid do |t|
      t.references :question, type: :uuid
      t.string :response, null: false
      t.timestamps
    end
  end

  def down
    drop_table :short_text_answers
  end
end
