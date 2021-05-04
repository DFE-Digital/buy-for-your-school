class AddSectionOrder < ActiveRecord::Migration[6.1]
  def change
    add_column :sections, :order, :integer
  end
end
