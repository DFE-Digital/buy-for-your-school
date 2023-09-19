class AddFlowToRequestForHelpCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :request_for_help_categories, :flow, :int
  end
end
