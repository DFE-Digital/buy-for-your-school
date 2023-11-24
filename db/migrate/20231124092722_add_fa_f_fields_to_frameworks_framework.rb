class AddFaFFieldsToFrameworksFramework < ActiveRecord::Migration[7.1]
  def change
    change_table :frameworks_frameworks, bulk: true do |t|
      t.datetime :faf_added_date
      t.datetime :faf_end_date
    end
  end
end
