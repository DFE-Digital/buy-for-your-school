class ReseedEmailTemplateGroup < ActiveRecord::Migration[7.2]
  def up
    Rake::Task["case_management:seed_email_template_groups"].invoke
  end

  def down; end
end
