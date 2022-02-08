module Support
  class CaseMergeEmailsFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      required(:merge_into_case_id).value(:string)
    end

    rule(:merge_into_case_id) do
      key.failure(:missing) if value.blank?
    end
  end
end
