class AddPrimaryCallToActionTextToStep < ActiveRecord::Migration[6.0]
  def change
    add_column :steps, :primary_call_to_action_text, :string
  end
end
