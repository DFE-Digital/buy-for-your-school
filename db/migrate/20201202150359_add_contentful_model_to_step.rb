class AddContentfulModelToStep < ActiveRecord::Migration[6.0]
  def up
    add_column :steps, :contentful_model, :string
    Step.update_all(contentful_model: "question")
  end

  def down
    remove_column :steps, :contentful_model
  end
end
