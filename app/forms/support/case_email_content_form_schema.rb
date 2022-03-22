module Support
  class CaseEmailContentFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      optional(:email_body).value(:string)
      required(:email_subject).value(:string)
      optional(:email_template).value(:string)
      required(:text).value(:string)
    end

    rule(:text) do
      key(:text).failure(:missing) if value.blank? && EmailTemplates.basic_template?(values[:email_template])
    end

    rule(:email_subject) do
      key(:email_subject).failure(:missing) if value.blank?
    end
  end
end
