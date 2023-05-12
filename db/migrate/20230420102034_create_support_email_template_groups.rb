class CreateSupportEmailTemplateGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :support_email_template_groups, id: :uuid do |t|
      t.string :title, null: false
      t.references :parent, foreign_key: { to_table: :support_email_template_groups }, type: :uuid
      t.boolean :archived, default: false, null: false
      t.datetime :archived_at
      t.timestamps
    end
  end
end
