class AddTimestampDefaultsToSupportFrameworks < ActiveRecord::Migration[6.1]
  def change
    change_table :support_frameworks, bulk: true do |t|
      t.change_default :created_at, from: nil, to: -> { "current_timestamp" }
      t.change_default :updated_at, from: nil, to: -> { "current_timestamp" }
    end
  end
end
