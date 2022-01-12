class ChangeActiveStorageAttachmentsRecordIdToUuid < ActiveRecord::Migration[6.1]
  def up
    # There should be NO records in this table at this point!
    execute "ALTER TABLE active_storage_attachments ALTER COLUMN record_id SET DATA TYPE UUID USING (uuid_generate_v4());"
  end

  def down
    # There should be NO records in this table at this point!
    execute "ALTER TABLE active_storage_attachments ALTER COLUMN record_id SET DATA TYPE bigint USING 0;"
  end
end
