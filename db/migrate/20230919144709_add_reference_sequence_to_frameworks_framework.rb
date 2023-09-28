class AddReferenceSequenceToFrameworksFramework < ActiveRecord::Migration[7.0]
  def change
    create_sequence :framework_refs
    change_column_default :frameworks_frameworks, :reference, to: -> { "'F' || nextval('framework_refs')" }, from: nil
    add_column :frameworks_frameworks, :provider_reference, :string
  end
end
