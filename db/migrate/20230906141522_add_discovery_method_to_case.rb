class AddDiscoveryMethodToCase < ActiveRecord::Migration[7.0]
  def change
    change_table :support_cases, bulk: true do |t|
      t.integer :discovery_method
      t.string :discovery_method_other_text
    end
  end
end
