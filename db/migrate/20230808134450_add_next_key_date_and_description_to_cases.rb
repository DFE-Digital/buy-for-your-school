class AddNextKeyDateAndDescriptionToCases < ActiveRecord::Migration[7.0]
  def change
    change_table :support_cases, bulk: true do |t|
      t.column :next_key_date, :date
      t.column :next_key_date_description, :string
    end
  end
end
