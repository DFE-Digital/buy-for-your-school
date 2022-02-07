# :nocov:
module Support
  class CaseOrganisationFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      required(:establishment_id).value(:string)
    end

    rule(:establishment_id) do
      key(:establishment_id).failure(:missing) if value.blank?
    end
  end
end
# :nocov:
