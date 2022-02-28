class CreateSupportCaseData < ActiveRecord::Migration[6.1]
  def change
    create_view :support_case_data
  end
end
