class CreateFrameworksFrameworks < ActiveRecord::Migration[7.0]
  def change
    create_table :frameworks_frameworks, id: :uuid do |t|
      t.integer :status, default: 0
      t.string :provider_url
      t.string :provider_reference
      t.string :name
      t.string :short_name
      t.string :description
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :published_on_faf
      t.uuid :provider_id, null: false
      t.timestamps
    end
  end
end
