class RemoveAboutProcurementFromRequests < ActiveRecord::Migration[7.0]
  def change
    tables = %i[support_requests framework_requests]

    tables.each do |table|
      remove_column table, :about_procurement, :boolean
    end
  end
end
