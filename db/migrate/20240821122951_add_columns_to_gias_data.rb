class AddColumnsToGiasData < ActiveRecord::Migration[7.1]
  def change
    change_table :support_organisations, bulk: true do |t|
      t.column :archived, :boolean
      t.column :archived_at, :datetime
      t.column :closed_date, :date
      t.column :reason_establishment_opened, :string
      t.column :reason_establishment_closed, :string
    end

    change_table :support_establishment_groups, bulk: true do |t|
      t.column :archived, :boolean
      t.column :archived_at, :datetime
      t.column :opened_date, :date
      t.column :closed_date, :date
    end

    change_table :local_authorities, bulk: true do |t|
      t.column :archived, :boolean
      t.column :archived_at, :datetime
    end
  end
end
