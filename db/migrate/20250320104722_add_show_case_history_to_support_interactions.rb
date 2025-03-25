class AddShowCaseHistoryToSupportInteractions < ActiveRecord::Migration[7.2]
  def change
    add_column :support_interactions, :show_case_history, :boolean, default: true
  end
end
