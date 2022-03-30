module Support
  #
  # Validate "create a new case" form details
  #
  class CreateCaseFormSchema < ::Support::Schema
    config.messages.top_namespace = :case_migration_form

    params do
      required(:first_name).value(:string)
      required(:last_name).value(:string)
      required(:email).value(:string)
      required(:source).value(:string)
      required(:request_text).value(:string)
      optional(:request_type).value(:bool)
      optional(:organisation_id).value(:string)
      optional(:organisation_type).value(:string)
      optional(:organisation_name).value(:string)
      optional(:organisation_urn).value(:string)
      optional(:phone_number).value(:string)
      optional(:extension_number).value(:string)
      optional(:category_id).value(:string)
    end

    # TODO: custom macro for phone number validation
    rule(:phone_number).validate(max_size?: 13, format?: /^$|^(0|\+?44)[12378]\d{8,9}$/)

    # TODO: add email validation format
    rule(:email) do
      key(:email).failure(:missing) if value.blank?
    end

    rule(:first_name) do
      key(:first_name).failure(:missing) if value.blank?
    end

    rule(:last_name) do
      key(:last_name).failure(:missing) if value.blank?
    end

    rule(:organisation_id) do
      key(:organisation_id).failure(:missing) if value.blank?
    end

    rule(:category_id) do
      key.failure(:missing) if values[:request_type].presence && value.blank?
    end

    rule(:organisation_type) do
      key(:organisation_id).failure(:missing) if value.blank?
    end

    rule(:organisation_name) do
      key(:organisation_id).failure(:missing) if value.blank?
    end

    rule(:source) do
      key(:source).failure(:missing) if value.blank?
    end

    rule(:request_text) do
      key(:request_text).failure(:missing) if value.blank?
    end

  end
end
