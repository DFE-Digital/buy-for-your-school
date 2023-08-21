class AddSchoolsToFrameworkRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :framework_requests, :school_urns, :string, array: true, default: []
  end
end
