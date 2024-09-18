class RecreateSupportCaseDataAfterDroppingViews < ActiveRecord::Migration[7.1]
  def change
    execute "DROP VIEW IF EXISTS support_tower_cases CASCADE;"
    create_view :support_tower_cases, version: 4
    create_view :support_case_data, version: 12
  end
end
