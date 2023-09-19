class AddDocumentTypesToFrameworkRequests < ActiveRecord::Migration[7.0]
  def change
    change_table :framework_requests, bulk: true do |t|
      t.column :document_types, :string, array: true, default: []
      t.column :document_type_other, :text
    end
  end
end
