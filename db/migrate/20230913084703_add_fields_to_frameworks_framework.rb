class AddFieldsToFrameworksFramework < ActiveRecord::Migration[7.0]
  def change
    change_table :frameworks_frameworks, bulk: true do |t|
      t.boolean :dps, default: true
      t.boolean :lot, default: 0
    end
  end
end
