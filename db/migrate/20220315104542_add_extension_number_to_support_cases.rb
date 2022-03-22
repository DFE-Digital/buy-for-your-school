class AddExtensionNumberToSupportCases < ActiveRecord::Migration[6.1]
  def change
    change_table :support_cases, bulk: true do |t|
      t.string :extension_number
    end
  end
end
