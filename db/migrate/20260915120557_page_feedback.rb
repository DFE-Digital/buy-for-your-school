class PageFeedback < ActiveRecord::Migration[7.2]
  def change
    create_table :page_feedbacks do |t|
      t.string :page_url, null: false
      t.boolean :page_useful, null: false
      t.boolean :wants_feedback
      t.text :feedback

      t.timestamps
    end
  end
end
