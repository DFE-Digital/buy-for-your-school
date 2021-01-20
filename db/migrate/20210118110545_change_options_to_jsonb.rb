class ChangeOptionsToJsonb < ActiveRecord::Migration[6.1]
  def change
    remove_column :steps, :options
    add_column :steps, :options, :jsonb
  end
end
