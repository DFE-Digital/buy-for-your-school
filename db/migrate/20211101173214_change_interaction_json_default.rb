class ChangeInteractionJsonDefault < ActiveRecord::Migration[6.1]
  def change
    change_column_default :support_interactions, :additional_data, from: "{}", to: {}
  end
end
