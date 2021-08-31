class AddTimestampDefaultsToCategories < ActiveRecord::Migration[6.1]
  def change
    change_column_default :categories, :created_at, from: nil, to: -> { "current_timestamp" }
    change_column_default :categories, :updated_at, from: nil, to: -> { "current_timestamp" }
  end
end
