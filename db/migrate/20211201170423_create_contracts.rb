class CreateContracts < ActiveRecord::Migration[6.1]
  def change
    create_table :contracts, id: :uuid do |t|
      t.timestamps

      t.string :type
      t.string :supplier
      t.date :started_at
      t.date :ended_at
      t.interval :duration
      t.decimal :spend, precision: 9, scale: 2
    end
  end
end
