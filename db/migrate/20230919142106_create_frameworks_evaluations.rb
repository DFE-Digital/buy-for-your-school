class CreateFrameworksEvaluations < ActiveRecord::Migration[7.0]
  def change
    create_sequence :evaluation_refs
    create_table :frameworks_evaluations, id: :uuid do |t|
      t.string :reference, default: -> { "'FE' || nextval('evaluation_refs')" }
      t.uuid :framework_id
      t.uuid :assignee_id
      t.uuid :contact_id
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
