class SupportFormRefactor < ActiveRecord::Migration[6.1]
  def change
    rename_column(:support_requests, :message, :message_body)
    remove_columns(:support_requests, :school_name, :school_urn, type: :string, null: false)
  end
end
