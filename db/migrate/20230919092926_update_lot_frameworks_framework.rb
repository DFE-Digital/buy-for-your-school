class UpdateLotFrameworksFramework < ActiveRecord::Migration[7.0]
  def change
    change_column_default :frameworks_frameworks, :lot, from: 0, to: nil
    change_column :frameworks_frameworks, :lot, :integer, using: "lot::integer", default: 0
  end
end
