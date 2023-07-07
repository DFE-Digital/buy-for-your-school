class AddRefToSupportFrameworks < ActiveRecord::Migration[7.0]
  def change
    add_column :support_frameworks, :ref, :string
    add_index :support_frameworks, :ref, unique: true
  end
end
