module Support
  #
  # Validate "create a new case" form details
  #
  class CreateCaseFormSchema < ::Support::Schema
    config.messages.top_namespace = :case_migration_form

    params do
      required(:school_urn).value(:string)
      required(:first_name).value(:string)
      required(:last_name).value(:string)
      required(:email).value(:string)
      optional(:request_type).value(:bool)
      optional(:organisation_id).value(:string)
      optional(:phone_number).value(:string)
      optional(:category_id).value(:string)
      optional(:hub_case_ref).value(:string)
      optional(:estimated_procurement_completion_date).value(:string)
      optional(:estimated_savings).value(:string)
      optional(:hub_notes).value(:string)
      optional(:progress_notes).value(:string)
    end

    # TODO: custom macro for phone number validation
    rule(:phone_number).validate(max_size?: 13, format?: /^$|^(0|\+?44)[12378]\d{8,9}$/)

    # TODO: custom macro using chronic
    rule(:estimated_procurement_completion_date).validate(format?: /(^$|^\d{2}\/\d{2}\/\d{4}$)/)

    rule(:school_urn) do
      key(:school_urn).failure(:missing) if value.blank?
      key(:school_urn).failure(:invalid) if invalid_school_urn?(value)
    end

    # TODO: add email validation format
    rule(:email) do
      key(:email).failure(:missing) if value.blank?
    end

  private

    def invalid_school_urn?(value)
      return true if value.blank?

      Support::Organisation.find_by(urn: value).nil?
    end
  end
end
