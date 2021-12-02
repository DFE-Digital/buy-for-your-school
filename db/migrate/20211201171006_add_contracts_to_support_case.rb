class AddContractsToSupportCase < ActiveRecord::Migration[6.1]
  def change
    add_reference :support_cases, :existing_contract, null: true, foreign_key: { to_table: :contracts }, type: :uuid
    add_reference :support_cases, :new_contract, null: true, foreign_key: { to_table: :contracts }, type: :uuid
  end
end
