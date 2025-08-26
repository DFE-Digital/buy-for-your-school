class DropExitSurveys < ActiveRecord::Migration[7.2]
  def up
    drop_table :exit_survey_responses
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
