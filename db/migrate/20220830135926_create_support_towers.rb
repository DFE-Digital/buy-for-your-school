class CreateSupportTowers < ActiveRecord::Migration[7.0]
  def change
    create_view :support_towers
  end
end
