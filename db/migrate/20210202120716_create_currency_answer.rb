class CreateCurrencyAnswer < ActiveRecord::Migration[6.1]
  def up
    create_table :currency_answers, id: :uuid do |t|
      t.references :step, type: :uuid
      t.decimal :response, null: false, precision: 11, scale: 2
      t.timestamps
    end
  end

  def down
    drop_table :currency_answers
  end
end
