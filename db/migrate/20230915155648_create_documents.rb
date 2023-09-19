class CreateDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :documents, id: :uuid do |t|
      t.integer :submission_status, default: 0
      t.string :filename
      t.integer :filesize
      t.references :support_case, foreign_key: { to_table: :support_cases }, type: :uuid
      t.references :framework_request, foreign_key: { to_table: :framework_requests }, type: :uuid

      t.timestamps
    end
  end
end
