class AddSupportCaseToFrameworkRequests < ActiveRecord::Migration[7.0]
  def change
    add_reference :framework_requests, :support_case, foreign_key: { to_table: :support_cases }, type: :uuid
  end
end
