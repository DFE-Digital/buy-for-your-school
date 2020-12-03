class ChangeLongTextAnswerToUuid < ActiveRecord::Migration[6.0]
  def up
    enable_extension "uuid-ossp" unless extension_enabled?("uuid-ossp")

    add_column :long_text_answers, :uuid, :uuid, default: "gen_random_uuid()", null: false

    change_table :long_text_answers do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE long_text_answers ADD PRIMARY KEY (id);"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
