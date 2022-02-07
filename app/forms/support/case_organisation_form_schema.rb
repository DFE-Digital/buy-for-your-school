# :nocov:
module Support
  class CaseOrganisationFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      required(:organisation_id).value(:string)
    end

    rule(:organisation_id) do
      key(:organisation_id).failure(:missing) if value.blank?
    end
  end
end
# :nocov:
