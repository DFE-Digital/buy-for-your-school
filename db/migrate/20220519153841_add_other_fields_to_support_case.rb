class AddOtherFieldsToSupportCase < ActiveRecord::Migration[6.1]
  def change
    change_table :support_cases, bulk: true do |t|
      t.column :other_category, :string
      t.column :other_query, :string
    end
  end
end
