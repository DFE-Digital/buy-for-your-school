class AddWithSchoolFlagToCases < ActiveRecord::Migration[7.0]
  def change
    add_column :support_cases, :with_school, :boolean, default: false, null: false
  end
end
