class RemoveLiquidTemplateFromJourneys < ActiveRecord::Migration[6.1]
  def change
    remove_column :journeys, :liquid_template, :jsonb
  end
end
