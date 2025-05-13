class Energy::VatRateChargeFormSchema < Schema
  config.messages.top_namespace = :vat_rate_charge

  params do
    required(:vat_rate).value(:integer)
    required(:vat_lower_rate_percentage).value(:integer)
  end

  rule(:vat_rate) do
    key.failure(:missing) if value.blank?
  end

  rule(:vat_lower_rate_percentage) do
    key.failure(:missing) if value.blank? && values[:vat_rate] == 5
  end
end