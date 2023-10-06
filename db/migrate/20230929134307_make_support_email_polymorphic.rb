class MakeSupportEmailPolymorphic < ActiveRecord::Migration[7.0]
  def up
    add_column :support_emails, :ticket_type, :string
    add_column :support_emails, :ticket_id, :uuid

    execute <<-SQL
      UPDATE support_emails
      SET ticket_type = (CASE WHEN case_id IS NULL THEN NULL ELSE 'Support::Case' END),
          ticket_id = case_id
    SQL
  end

  def down
    remove_column :support_emails, :ticket_type, :string
    remove_column :support_emails, :ticket_id, :uuid
  end
end
