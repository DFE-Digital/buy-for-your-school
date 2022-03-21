class ChangeClosureReasonToEnum < ActiveRecord::Migration[6.1]
  def up
    remove_column :support_cases, :closure_reason
    add_column :support_cases, :closure_reason, :integer
  end

  def down
    remove_column :support_cases, :closure_reason
    add_column :support_cases, :closure_reason, :string
  end
end
