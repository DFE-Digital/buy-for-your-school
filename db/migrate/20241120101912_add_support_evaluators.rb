class AddSupportEvaluators < ActiveRecord::Migration[7.2]
  def change
    create_table "support_evaluators", id: :uuid do |t|
      t.references "support_case", type: :uuid
      t.string "first_name", null: false
      t.string "last_name", null: false
      t.string "email", null: false
      t.string "dsi_uid", default: "", null: false
      t.timestamps
      t.index %w[dsi_uid]
      t.index %w[email support_case_id], unique: true
    end
  end
end
