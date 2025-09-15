class EnergyEmailTemplateConfigurations < ActiveRecord::Migration[7.2]
  def change
    create_table :energy_email_template_configurations, id: :uuid do |t|
      t.column :energy_type, :integer
      t.column :configure_option, :integer
      t.references :support_email_templates, type: :uuid
      t.string :to_email_ids, default: [], array: true
      t.string :cc_email_ids, default: [], array: true
      t.string :bcc_email_ids, default: [], array: true
      t.timestamps
    end
  end
end
