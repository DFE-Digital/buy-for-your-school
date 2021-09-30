class AddAgentReferencesToSupportCases < ActiveRecord::Migration[6.1]
  def change
    add_column :support_cases, :agent_id, :uuid, class_name: "Support::Agent", index: true
  end
end
