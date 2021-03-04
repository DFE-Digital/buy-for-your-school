class AddSkippableToStep < ActiveRecord::Migration[6.1]
  def change
    add_column :steps, :skip_call_to_action_text, :string, default: nil
  end
end
