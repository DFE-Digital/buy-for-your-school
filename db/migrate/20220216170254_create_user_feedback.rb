class CreateUserFeedback < ActiveRecord::Migration[6.1]
  def change
    create_table :user_feedback, id: :uuid do |t|
      t.integer :service, null: false
      t.integer :satisfaction, null: false
      t.string :feedback_text
      t.boolean :logged_in, null: false

      t.timestamps
    end
  end
end
