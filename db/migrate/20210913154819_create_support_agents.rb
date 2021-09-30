class CreateSupportAgents < ActiveRecord::Migration[6.1]
  def change
    create_table :support_agents, id: :uuid do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.timestamps
    end
  end
end
