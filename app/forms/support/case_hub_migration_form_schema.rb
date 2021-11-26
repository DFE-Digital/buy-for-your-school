module Support
  #
  # Validate "create a new case" form details for a Hub migration case
  #
  class CaseHubMigrationFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      required(:school_urn).value(:string)
      required(:first_name).value(:string)
      required(:last_name).value(:string)
      required(:email).value(:string)
      optional(:organisation_id).value(:string)
      optional(:phone_number).value(:string)
      optional(:category_id).value(:string)
      optional(:hub_case_ref).value(:string)
      optional(:estimated_procurement_completion_date).value(:date)
      optional(:estimated_savings).value(:string)
      optional(:hub_notes).value(:string)
      optional(:progress_notes).value(:string)
    end

    # TODO: add phone number validation format
    rule(:phone_number) do
      key(:phone_number).failure(:missing) if value.blank?
    end

    rule(:school_urn) do
      key(:school_urn).failure(:missing) if value.blank?
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
  end
end
