class AddClosureReasonToSupportCases < ActiveRecord::Migration[6.1]
  def change
    add_column :support_cases, :closure_reason, :string
  end
end
