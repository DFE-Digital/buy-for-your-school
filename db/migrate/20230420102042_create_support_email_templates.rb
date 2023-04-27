class CreateSupportEmailTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :support_email_templates, id: :uuid do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.references :template_group, foreign_key: { to_table: :support_email_template_groups }, type: :uuid, null: false
      t.integer :stage
      t.string :subject
      t.text :body, null: false
      t.boolean :archived, default: false, null: false
      t.datetime :archived_at
      t.references :created_by, foreign_key: { to_table: :support_agents }, type: :uuid
      t.references :updated_by, foreign_key: { to_table: :support_agents }, type: :uuid
      t.timestamps
    end
  end
end
