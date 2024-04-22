class CreateFrameworksFrameworkData < ActiveRecord::Migration[7.1]
  def change
    create_view :frameworks_framework_data
  end
end
