class AddActionRequiredToSupportCases < ActiveRecord::Migration[6.1]
  def change
    add_column :support_cases, :action_required, :boolean, default: false
  end
end
