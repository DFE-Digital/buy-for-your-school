class CreateCheckboxAnswers < ActiveRecord::Migration[6.0]
  def change
    create_table :checkbox_answers, id: :uuid do |t|
      t.references :step, type: :uuid
      t.string :response, array: true, default: []
      t.timestamps
    end
  end
end
