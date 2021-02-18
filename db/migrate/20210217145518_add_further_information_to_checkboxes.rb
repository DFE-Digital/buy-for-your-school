class AddFurtherInformationToCheckboxes < ActiveRecord::Migration[6.1]
  def change
    add_column :checkbox_answers, :further_information, :text
  end
end
