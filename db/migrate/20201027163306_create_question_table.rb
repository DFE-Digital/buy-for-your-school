class CreateQuestionTable < ActiveRecord::Migration[6.0]
  def change
    create_table :questions, id: :uuid do |t|
      t.references :plan, type: :uuid
      t.string :title, null: false
      t.string :help_text
      t.string :contentful_type, null: false
      t.string :options, array: true
      t.binary :raw, null: false
      t.timestamps
    end
  end
end
