class AddUserDataToUserFeedback < ActiveRecord::Migration[6.1]
  def change
    change_table :user_feedback, bulk: true do |t|
      t.string :full_name
      t.string :email
      t.belongs_to :logged_in_as, foreign_key: { to_table: :users }, type: :uuid
    end
  end
end
