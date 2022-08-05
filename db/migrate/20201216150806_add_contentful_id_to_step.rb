class AddContentfulIdToStep < ActiveRecord::Migration[6.1]
  def up
    add_column :steps, :contentful_id, :string

    ActiveRecord::Base.transaction do
      Step.all.map do |step|
        contentful_id = JSON.parse(
          step.raw.gsub("=>", ":"),
        ).dig("sys", "id")
        step.update!(contentful_id:)
      end
    end

    change_column :steps, :contentful_id, :string, null: false
  end

  def down
    remove_column :steps, :contentful_id, :string
  end
end
