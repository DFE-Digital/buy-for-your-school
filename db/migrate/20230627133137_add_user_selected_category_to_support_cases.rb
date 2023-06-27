class AddUserSelectedCategoryToSupportCases < ActiveRecord::Migration[7.0]
  def change
    change_table :support_cases, bulk: true do |t|
      t.column :user_selected_category, :text
    end
  end
end
