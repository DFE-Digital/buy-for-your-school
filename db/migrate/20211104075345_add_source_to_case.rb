class AddSourceToCase < ActiveRecord::Migration[6.1]
  def up
    add_column :support_cases, :source, :integer, index: true
  end
end
