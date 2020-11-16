class CreateLongTextAnswer < ActiveRecord::Migration[6.0]
  def change
    create_table :long_text_answers do |t|
      t.references :question, type: :uuid
      t.text :response, null: false
      t.timestamps
    end
  end
end
