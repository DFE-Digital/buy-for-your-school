class AddUniqueIndexToSupportFrameworks < ActiveRecord::Migration[6.1]
  def change
    add_index :support_frameworks, %i[name supplier], unique: true
  end
end
