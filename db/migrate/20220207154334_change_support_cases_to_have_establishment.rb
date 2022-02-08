class ChangeSupportCasesToHaveEstablishment < ActiveRecord::Migration[6.1]
  def change
    add_column :support_cases, :organisation_type, :string

    Support::Case.where.not(organisation_id: nil).update_all(organisation_type: 'Support::Organisation')
  end
end
