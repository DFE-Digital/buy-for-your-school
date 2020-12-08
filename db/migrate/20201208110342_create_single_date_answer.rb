class CreateSingleDateAnswer < ActiveRecord::Migration[6.0]
  def change
    create_table :single_date_answers, id: :uuid do |t|
      t.references :step, type: :uuid
      t.date :response, null: false
      t.timestamps
    end
  end
end
