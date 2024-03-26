class CreateLocalAuthorities < ActiveRecord::Migration[7.1]
  def change
    create_table :local_authorities, id: :uuid do |t|
      t.string :la_code, null: false
      t.index :la_code, unique: true
      t.string :name, null: false
      t.index :name, unique: true
      t.timestamps
    end

    reversible do |direction|
      change_table :support_organisations do |t|
        direction.up   { t.rename :local_authority, :local_authority_legacy }
        direction.down { t.rename :local_authority_legacy, :local_authority }
      end
    end

    add_reference :support_organisations, :local_authority, type: :uuid, foreign_key: true
  end
end
