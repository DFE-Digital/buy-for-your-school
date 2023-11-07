class AddCreationSourceToFrameworksEvaluations < ActiveRecord::Migration[7.0]
  def change
    add_column :frameworks_evaluations, :creation_source, :integer, default: 0
  end
end
