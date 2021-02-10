class AddHiddenStateToStep < ActiveRecord::Migration[6.1]
  def change
    add_column :steps, :hidden, :boolean, default: false
  end
end
