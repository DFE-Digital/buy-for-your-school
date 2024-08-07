class AddOtherSchoolUrnToCase < ActiveRecord::Migration[7.1]
  def change
    add_column :support_cases, :other_school_urns, :string, array: true, default: []
  end
end
