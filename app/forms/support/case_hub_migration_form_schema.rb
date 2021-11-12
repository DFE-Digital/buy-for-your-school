module Support
  #
  # Validate "create a new case" form details for a Hub migration case
  #
  class CaseHubMigrationFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      required(:school_urn).value(:string)
      required(:contact_name).value(:string)
      required(:contact_email).value(:string)
      optional(:contact_phone_number).value(:string)
      optional(:buying_category).value(:string)
      optional(:hub_case_ref).value(:string)
      optional(:estimated_procurement_completion_date).value(:string)
      optional(:estimated_savings).value(:string)
      optional(:hub_notes).value(:string)
      optional(:progress_notes).value(:string)
    end

    rule(:contact_phone_number) do
      key(:contact_phone_number).failure(:missing) if value.blank?
    end

    rule(:school_urn) do
      key(:school_urn).failure(:missing) if value.blank?
    end

    rule(:contact_name) do
      key(:contact_name).failure(:missing) if value.blank?
    end

    rule(:contact_email) do
      key(:contact_email).failure(:missing) if value.blank?
    end
  end
end
