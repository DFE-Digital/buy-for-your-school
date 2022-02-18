class AddUserDataToUserFeedback < ActiveRecord::Migration[6.1]
  def change
    add_reference :user_feedback, :logged_in_as, foreign_key: { to_table: :users }, type: :uuid
    add_column :user_feedback, :full_name, :string
    add_column :user_feedback, :email, :string
  end
end
