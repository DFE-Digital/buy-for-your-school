class Energy::VatRateChargeFormSchema < Schema
  config.messages.top_namespace = :vat_rate_charge

  params do
    required(:vat_rate).value(:integer)
    required(:vat_lower_rate_percentage).value(:integer)
    optional(:vat_lower_rate_reg_no).value(:string)
  end

  rule(:vat_rate) do
    key.failure(:missing) if value.zero?
  end

  rule(:vat_lower_rate_percentage) do
    if values[:vat_rate] == 5
      key.failure(:missing) if value.zero?
      key.failure(:invalid_range) if value < 1 || value > 100
    end
  end
end
