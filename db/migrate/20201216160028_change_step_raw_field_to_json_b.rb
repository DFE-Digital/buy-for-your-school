class ChangeStepRawFieldToJsonB < ActiveRecord::Migration[6.1]
  def up
    add_column :steps, :raw_jsonb, :jsonb, null: false
    ActiveRecord::Base.transaction do
      Step.all.map do |step|
        hash = JSON.parse(step.raw.gsub("=>", ":"))
        step.update(raw_jsonb: hash)
      end
    end
    remove_column :steps, :raw
    rename_column :steps, :raw_jsonb, :raw
  end

  def down
    add_column :steps, :raw_binary, :binary, null: false
    ActiveRecord::Base.transaction do
      Step.all.map do |step|
        string = step.raw.to_s
        step.update(raw_binary: string)
      end
    end
    remove_column :steps, :raw
    rename_column :steps, :raw_binary, :raw
  end
end
