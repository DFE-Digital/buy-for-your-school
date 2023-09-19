class AddContractLengthToFrameworkRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :framework_requests, :contract_length, :integer
  end
end
