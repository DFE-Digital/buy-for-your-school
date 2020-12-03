class AddBodyToSteps < ActiveRecord::Migration[6.0]
  def change
    add_column :steps, :body, :text
  end
end
