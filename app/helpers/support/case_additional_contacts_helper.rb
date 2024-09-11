module Support
  module CaseAdditionalContactsHelper
    def role_options
      CheckboxOption.from(I18nOption.from("support.case_additional_contact.role.options.%%key%%", Support::CaseAdditionalContact.role_values), exclusive_fields: %w[none])
    end
  end
end
