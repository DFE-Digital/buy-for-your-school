class AddLiquidTemplateToJourney < ActiveRecord::Migration[6.1]
  def change
    # Journeys already exist in real environments from our tests, we can delete them all and set the null validation
    add_column :journeys, :liquid_template, :jsonb, null: false
  end
end
