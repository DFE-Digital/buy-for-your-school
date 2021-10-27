module Support
  class CaseEmailContentFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      required(:email_body).value(:string)
    end

    rule(:email_body) do
      key(:email_body).failure(:missing) if value.blank?
    end
  end
end
