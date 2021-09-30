class AddValidationCriteriaToSteps < ActiveRecord::Migration[6.1]
  def change
    add_column :steps, :criteria, :jsonb
  end
end
