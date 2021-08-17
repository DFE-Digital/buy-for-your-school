class CreateSchoolUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :school_users, id: :uuid do |t|
      t.uuid :school_id, null: false, index: true
      t.uuid :user_id, null: false, index: true
      t.timestamps
    end
  end
end
