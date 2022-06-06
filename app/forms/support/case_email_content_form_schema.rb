module Support
  class CaseEmailContentFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      optional(:email_body).value(:string)
      required(:email_subject).value(:string)
      optional(:email_template).value(:string)
    end

    rule(:email_subject) do
      key(:email_subject).failure(:missing) if value.blank?
    end
  end
end
