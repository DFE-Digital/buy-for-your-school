class CreateSupportEnquiries < ActiveRecord::Migration[6.1]
  def change
    create_table :support_enquiries, id: :uuid do |t|
      t.uuid :support_request_id
      t.uuid :case_id
      t.string :name
      t.string :email
      t.string :telephone
      t.string :school_urn
      t.string :school_name
      t.string :category
      t.string :message
      t.timestamps

      t.index :support_request_id
      t.index :case_id
    end
  end
end
