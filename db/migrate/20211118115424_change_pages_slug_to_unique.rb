class ChangePagesSlugToUnique < ActiveRecord::Migration[6.1]
  def change
    add_index :pages, :slug, unique: true 
  end
end
