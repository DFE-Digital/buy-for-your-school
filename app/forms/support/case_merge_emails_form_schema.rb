module Support
  class CaseMergeEmailsFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      required(:merge_into_case_ref).value(:string)
      required(:merge_from_case_ref).value(:string)
    end

    rule(:merge_into_case_ref) do
      key.failure(:missing) unless Case.find_by(ref: value)
    end

    rule do
      if values[:merge_into_case_ref] == values[:merge_from_case_ref]
        base.failure('You cannot merge into the same case')
      end
    end
  end
end
