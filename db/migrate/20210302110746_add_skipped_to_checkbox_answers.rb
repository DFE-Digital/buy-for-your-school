class AddSkippedToCheckboxAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :checkbox_answers, :skipped, :boolean, default: false
  end
end
