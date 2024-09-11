module Support
  class CaseAdditionalContactFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      required(:first_name).value(:string)
      required(:last_name).value(:string)
      optional(:phone_number).value(:string)
      required(:email).value(:string)
      optional(:extension_number).value(:string)
    end

    rule(:email) do
      if value.blank?
        key(:email).failure(:missing)
      else
        key(:email).failure(:invalid_format) unless value.scan(URI::MailTo::EMAIL_REGEXP).any?
      end
    end
  end
end
