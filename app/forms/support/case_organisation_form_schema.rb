# :nocov:
module Support
  class CaseOrganisationFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      required(:organisation_id).value(:string)
      required(:organisation_type).value(:string)
    end

    rule(:organisation_id) do
      key(:organisation_id).failure(:missing) if value.blank?
    end

    rule(:organisation_type) do
      # intentional use of organisation_id - the user should only see 1 error around organisation
      key(:organisation_id).failure(:missing) if value.blank?
    end
  end
end
# :nocov:
