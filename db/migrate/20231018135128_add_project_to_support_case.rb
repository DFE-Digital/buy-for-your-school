class AddProjectToSupportCase < ActiveRecord::Migration[7.0]
  def change
    add_column :support_cases, :project, :string
  end
end
