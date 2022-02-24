module Support
  class CaseClosureFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      required(:reason).value(:string)
    end

    rule(:reason) do
      key.failure(:missing) if value.blank?
    end
  end
end
