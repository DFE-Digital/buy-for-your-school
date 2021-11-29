class RemoveOrgStringsFromCase < ActiveRecord::Migration[6.1]
  def up
    change_table :support_cases, bulk: true do |t|
      t.remove :organisation_name, :organisation_urn
    end
  end

  def down
    change_table :support_cases, bulk: true do |t|
      t.string :organisation_name
      t.string :organisation_urn
    end
  end
end
