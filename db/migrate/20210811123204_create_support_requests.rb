class CreateSupportRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :support_requests, id: :uuid do |t|
      t.jsonb :specification_ids, default: {}
      t.jsonb :category_ids, default: {}
      t.string :message
      t.uuid :school_id, null: false, index: true
      t.uuid :user_id, null: false, index: true
      t.timestamps
    end
  end
end
