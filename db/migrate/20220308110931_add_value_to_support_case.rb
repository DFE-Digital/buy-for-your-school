class AddValueToSupportCase < ActiveRecord::Migration[6.1]
  def change
    change_table :support_cases, bulk: true do |t|
      t.decimal :value, precision: 9, scale: 2
    end
  end
end
