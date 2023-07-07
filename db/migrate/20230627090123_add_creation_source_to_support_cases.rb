class AddCreationSourceToSupportCases < ActiveRecord::Migration[7.0]
  def change
    add_column :support_cases, :creation_source, :integer
  end
end
