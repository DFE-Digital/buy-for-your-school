class CreateRadioAnswerTable < ActiveRecord::Migration[6.0]
  def up
    create_table :radio_answers, id: :uuid do |t|
      t.references :question, type: :uuid
      t.string :response, null: false
      t.timestamps
    end
  end

  def down
    drop_table :radio_answers
  end
end
