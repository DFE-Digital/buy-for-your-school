class ReseedProcurementStages < ActiveRecord::Migration[7.2]
  def up
    Rake::Task["case_management:seed_procurement_stages"].invoke
  end

  def down; end
end
