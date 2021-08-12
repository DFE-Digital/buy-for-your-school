class CreateSchools < ActiveRecord::Migration[6.1]
  def change
    create_table :schools, id: :uuid do |t|
      t.string :name
      t.string :postcode

      t.timestamps
    end
  end
end
