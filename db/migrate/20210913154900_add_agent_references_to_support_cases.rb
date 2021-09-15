class AddAgentReferencesToSupportCases < ActiveRecord::Migration[6.1]
  def change
    add_reference :support_cases, :agent, class_name: "Support::Agent", index: true
  end
end
