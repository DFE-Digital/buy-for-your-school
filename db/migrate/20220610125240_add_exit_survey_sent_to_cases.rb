class AddExitSurveySentToCases < ActiveRecord::Migration[6.1]
  def change
    add_column :support_cases, :exit_survey_sent, :boolean, default: false
  end
end
