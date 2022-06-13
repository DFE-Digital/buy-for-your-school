class AddTriageAttributesToRequests < ActiveRecord::Migration[6.1]
  def change
    tables = %i[support_requests framework_requests]

    tables.each do |table|
      add_column table, :procurement_amount, :decimal, precision: 9, scale: 2
      add_column table, :confidence_level, :integer
      add_column table, :special_requirements, :string
      add_column table, :about_procurement, :boolean, default: true
    end
  end
end
