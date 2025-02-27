class AddHasUploadedContractHandovers < ActiveRecord::Migration[7.2]
  def change
    add_column :support_cases, :has_uploaded_contract_handovers, :boolean, default: false
  end
end
