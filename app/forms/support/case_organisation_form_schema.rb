module Support
  class CaseOrganisationFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      required(:organisation_formatted_name).value(:string)
    end

    rule(:organisation_formatted_name) do
      key(:organisation_formatted_name).failure(:missing) if value.blank?
    end
  end
end
