class AddSchoolUrnToSupportRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :support_requests, :school_urn, :string
  end
end
