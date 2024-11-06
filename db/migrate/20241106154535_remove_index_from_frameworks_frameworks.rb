class RemoveIndexFromFrameworksFrameworks < ActiveRecord::Migration[7.2]
  def change
    remove_index :frameworks_frameworks, %i[name provider_id]
  end
end
