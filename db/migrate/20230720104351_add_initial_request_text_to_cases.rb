class AddInitialRequestTextToCases < ActiveRecord::Migration[7.0]
  def change
    add_column :support_cases, :initial_request_text, :string
  end
end
