module Support
  #
  # Validate "create a new case" form details
  #
  class CreateCaseFormSchema < ::Support::Schema
    config.messages.top_namespace = :case_migration_form
    include Concerns::RequestDetailsFormFieldsSchema

    params do
      required(:first_name).value(:string)
      required(:last_name).value(:string)
      required(:email).value(:string)
      required(:source).value(:string)
      optional(:organisation_id).value(:string)
      optional(:organisation_type).value(:string)
      optional(:organisation_name).value(:string)
      optional(:organisation_urn).value(:string)
      optional(:phone_number).value(:string)
      optional(:extension_number).value(:string)

      # request_details fields
      required(:request_text).value(:string)
      optional(:request_type).value(:bool)
      optional(:category_id).value(:string)
      optional(:query_id).value(:string)
      optional(:other_category).value(:string)
      optional(:other_query).value(:string)
    end

    rule(:organisation_name) do
      key(:organisation_name).failure(:missing) if value.blank?
    end

    rule(:first_name) do
      key(:first_name).failure(:missing) if value.blank?
    end

    rule(:last_name) do
      key(:last_name).failure(:missing) if value.blank?
    end

    # TODO: add email validation format
    rule(:email) do
      key(:email).failure(:missing) if value.blank?
    end

    rule(:phone_number) do
      if value.present?
        key.failure(:max_size?) if value.length > 13
        key.failure(:format?)   unless /^$|^(0|\+?44)[12378]\d{8,9}$/.match?(value)
      end
    end

    rule(:source) do
      key(:source).failure(:missing) if value.blank?
    end
  end
end
