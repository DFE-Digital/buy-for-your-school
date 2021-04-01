class ChangeFurtherInformationToJsonForRadioAnswers < ActiveRecord::Migration[6.1]
  def up
    add_column :radio_answers, :further_information_jsonb, :jsonb
    ActiveRecord::Base.transaction do
      RadioAnswer.all.map do |radio|
        machine_value = radio.response.parameterize(separator: "_")
        hash = {machine_value => radio.further_information}
        radio.update(further_information_jsonb: hash)
      end
    end
    remove_column :radio_answers, :further_information
    rename_column :radio_answers, :further_information_jsonb, :further_information
  end

  def down
    add_column :radio_answers, :further_information_string, :string
    ActiveRecord::Base.transaction do
      RadioAnswer.all.map do |radio|
        machine_value = radio.response.parameterize(separator: "_")
        matching_further_information = radio.further_information[machine_value]
        radio.update(further_information_string: matching_further_information)
      end
    end
    remove_column :radio_answers, :further_information
    rename_column :radio_answers, :further_information_string, :further_information
  end
end
