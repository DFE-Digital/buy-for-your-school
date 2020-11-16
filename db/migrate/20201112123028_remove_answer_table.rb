class RemoveAnswerTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :answers
  end
end
