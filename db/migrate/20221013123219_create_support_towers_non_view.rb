class CreateSupportTowersNonView < ActiveRecord::Migration[7.0]
  def change
    create_table :support_towers, id: :uuid do |t|
      t.timestamps
      t.string :title
    end
  end
end
