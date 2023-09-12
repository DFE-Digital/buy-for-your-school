class CreateFrameworksProviderContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :frameworks_provider_contacts, id: :uuid do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.uuid :provider_id, null: false

      t.timestamps
    end
  end
end
