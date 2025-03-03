class AddSharedHandoverPackToCase < ActiveRecord::Migration[7.2]
  def change
    add_column :support_cases, :has_shared_handover_pack, :boolean, default: false
  end
end
