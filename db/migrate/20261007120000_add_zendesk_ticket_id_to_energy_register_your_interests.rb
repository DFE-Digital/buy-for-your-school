class AddZendeskTicketIdToEnergyRegisterYourInterests < ActiveRecord::Migration[8.1]
  def change
    add_column :energy_register_your_interests, :zendesk_ticket_id, :bigint
  end
end
