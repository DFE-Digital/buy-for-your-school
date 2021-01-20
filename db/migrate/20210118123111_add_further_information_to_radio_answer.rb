class AddFurtherInformationToRadioAnswer < ActiveRecord::Migration[6.1]
  def change
    add_column :radio_answers, :further_information, :text
  end
end
