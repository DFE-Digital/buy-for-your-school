class AddBreadcrumbsToPages < ActiveRecord::Migration[6.1]
  def up
    add_column :pages, :breadcrumbs, :string, array: true, default: []
  end

  def down
    remove_column :pages, :breadcrumbs
  end
end
