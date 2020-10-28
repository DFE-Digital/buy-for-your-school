class CreateAnswerTable < ActiveRecord::Migration[6.0]
  def change
    create_table :answers, id: :uuid do |t|
      t.references :question, type: :uuid
      t.string :response, null: false
      t.timestamps
    end
  end
end
