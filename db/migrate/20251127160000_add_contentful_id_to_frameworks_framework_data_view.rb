class AddContentfulIdToFrameworksFrameworkDataView < ActiveRecord::Migration[7.2]
  def change
    update_view :frameworks_framework_data, version: 2, revert_to_version: 1
  end
end
