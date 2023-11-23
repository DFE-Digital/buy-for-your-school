class RenameDfeEndDateToDfeReviewDate < ActiveRecord::Migration[7.1]
  def change
    rename_column :frameworks_frameworks, :dfe_end_date, :dfe_review_date
  end
end
