module Support
  class CaseEmailTypeFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      required(:choice).value(:string)
    end

    rule(:choice) do
      key(:choice).failure(:missing) if value.empty?
    end
  end
end
