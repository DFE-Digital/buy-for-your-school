class AddUniqueToCaseRef < ActiveRecord::Migration[6.1]
  def up
    change_column :support_cases, :ref, :string, unique: true
  end

  def down
    change_column :support_cases, :ref, :string
  end
end
