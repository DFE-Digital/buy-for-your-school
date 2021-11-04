module Support
  class CaseCategorisationFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      required(:category_id).value(:string)
    end

    rule(:category_id) do
      key(:category_id).failure(:missing) if value.blank?
    end
  end
end
