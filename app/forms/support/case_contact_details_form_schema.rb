module Support
  class CaseContactDetailsFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      optional(:first_name).value(:string)
      optional(:last_name).value(:string)
      optional(:phone).value(:string)
      required(:email).value(:string)
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
