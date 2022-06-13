class AddQueryToSupportCase < ActiveRecord::Migration[6.1]
  def change
    add_reference :support_cases, :query, foreign_key: { to_table: :support_queries }, type: :uuid
  end
end
