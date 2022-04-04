class CreateSupportFrameworks < ActiveRecord::Migration[6.1]
  def change
    create_table :support_frameworks, id: :uuid do |t|
      t.string :name
      t.string :supplier
      t.string :category
      t.date :expires_at

      t.timestamps
    end
  end
end
