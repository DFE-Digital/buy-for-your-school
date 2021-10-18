class AddJsonToInteractions < ActiveRecord::Migration[6.1]
  def change
    add_column :support_interactions, :additional_data, :jsonb, null: false, default: "{}"
  end
end
