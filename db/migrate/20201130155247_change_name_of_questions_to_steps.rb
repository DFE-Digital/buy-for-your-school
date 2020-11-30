class ChangeNameOfQuestionsToSteps < ActiveRecord::Migration[6.0]
  def self.up
    remove_foreign_key :radio_answers, :questions
    remove_foreign_key :short_text_answers, :questions
    remove_foreign_key :long_text_answers, :questions

    rename_table :questions, :steps
    rename_column :radio_answers, :question_id, :step_id
    rename_column :short_text_answers, :question_id, :step_id
    rename_column :long_text_answers, :question_id, :step_id

    add_foreign_key :radio_answers, :steps, on_delete: :cascade
    add_foreign_key :short_text_answers, :steps, on_delete: :cascade
    add_foreign_key :long_text_answers, :steps, on_delete: :cascade
  end

  def self.down
    remove_foreign_key :radio_answers, :steps
    remove_foreign_key :short_text_answers, :steps
    remove_foreign_key :long_text_answers, :steps

    rename_table :steps, :questions
    rename_column :radio_answers, :step_id, :question_id
    rename_column :short_text_answers, :step_id, :question_id
    rename_column :long_text_answers, :step_id, :question_id

    add_foreign_key :radio_answers, :questions, on_delete: :cascade
    add_foreign_key :short_text_answers, :questions, on_delete: :cascade
    add_foreign_key :long_text_answers, :questions, on_delete: :cascade
  end
end
