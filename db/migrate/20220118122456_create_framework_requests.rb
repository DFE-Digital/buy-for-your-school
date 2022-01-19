class CreateFrameworkRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :framework_requests, id: :uuid do |t|
      t.timestamps

      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :school_urn
      t.string :message_body
      t.boolean :submitted, default: false
    end
  end
end
