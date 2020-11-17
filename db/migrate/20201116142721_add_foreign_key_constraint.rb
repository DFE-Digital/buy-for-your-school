class AddForeignKeyConstraint < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :questions, :plans, on_delete: :cascade

    add_foreign_key :radio_answers, :questions, on_delete: :cascade
    add_foreign_key :short_text_answers, :questions, on_delete: :cascade
    add_foreign_key :long_text_answers, :questions, on_delete: :cascade
  end
end
