module Support
  class CaseResolutionFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      required(:notes).value(:string)
    end

    rule(:notes) do
      key(:notes).failure(:missing) if value.blank?
    end
  end
end
