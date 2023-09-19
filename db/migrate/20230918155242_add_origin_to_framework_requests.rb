class AddOriginToFrameworkRequests < ActiveRecord::Migration[7.0]
  def change
    change_table :framework_requests, bulk: true do |t|
      t.column :origin, :integer
      t.column :origin_other, :text
    end
  end
end
