class UpdateArchivedColumns < ActiveRecord::Migration[7.2]
  def up
    tables = %w[
      support_establishment_groups
      support_email_template_groups
      support_categories
      support_procurement_stages
      request_for_help_categories
      support_organisations
      local_authorities
      support_email_templates
    ]

    tables.each do |table|
      execute "UPDATE #{table} SET archived = false WHERE archived IS NULL;"

      change_column_default table, :archived, false
      change_column_null table, :archived, false
    end
  end

  def down
    tables = %w[
      support_establishment_groups
      support_email_template_groups
      support_categories
      support_procurement_stages
      request_for_help_categories
      support_organisations
      local_authorities
      support_email_templates
    ]

    tables.each do |table|
      change_column_default table, :archived, nil
      change_column_null table, :archived, true
    end
  end
end
