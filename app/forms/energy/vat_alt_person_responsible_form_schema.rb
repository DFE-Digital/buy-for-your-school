class Energy::VatAltPersonResponsibleFormSchema < Schema
  config.messages.top_namespace = :vat_alt_person_responsible

  option :organisation

  params do
    required(:vat_alt_person_first_name).value(:string, max_size?: 60)
    optional(:vat_alt_person_last_name).value(:string, max_size?: 60)
    required(:vat_alt_person_phone).value(:string)
    optional(:vat_alt_person_address).value(:hash)
  end

  rule(:vat_alt_person_first_name) do
    key.failure(:missing) if value.blank?
  end

  rule(:vat_alt_person_phone) do
    key.failure(:missing) if value.blank?
  end

  rule(:vat_alt_person_phone) do
    key.failure(:format?) if value && !value.match?(/\A(0\d{2,4}\s?\d{3,4}\s?\d{3,4})\z/)
  end

  rule(:vat_alt_person_address) do
    key.failure(:missing) if organisation.trust_code.present? && value.blank?
  end
end
