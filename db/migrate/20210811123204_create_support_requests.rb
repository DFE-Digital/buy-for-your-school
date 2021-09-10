class CreateSupportRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :support_requests, id: :uuid do |t|
      t.string :user_id
      t.uuid :journey_id
      t.uuid :category_id
      t.string :message
      t.string :school_name
      t.string :school_urn
      t.timestamps
      t.index :user_id
      t.index :journey_id
      t.index :category_id
    end
  end
end
