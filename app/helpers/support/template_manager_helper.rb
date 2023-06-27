module Support
  module TemplateManagerHelper
    def email_template_manager_editor(filter_url:)
      render "support/management/email_templates/template_manager/template_manager", mode: :edit, filter_url:, use_url: nil, hidden_fields_hash: {}
    end

    def email_template_manager_selector(filter_url:, use_url:, hidden_fields_hash: {})
      render "support/management/email_templates/template_manager/template_manager", mode: :select, filter_url:, use_url:, hidden_fields_hash:
    end
  end
end
