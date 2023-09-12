class CreateFrameworksProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :frameworks_providers, id: :uuid do |t|
      t.string :name
      t.string :short_name
      t.timestamps
    end
  end
end
