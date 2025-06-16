class Energy::VatRateChargeFormSchema < Schema
  config.messages.top_namespace = :vat_rate_charge

  params do
    required(:vat_rate).value(:integer)
    required(:vat_lower_rate_percentage).value(:string)
    optional(:vat_lower_rate_reg_no).value(:string)
  end

  rule(:vat_rate) do
    key.failure(:missing) if value.zero?
  end

  rule(:vat_lower_rate_percentage) do
    if values[:vat_rate] == 5
      if value.blank? || value == "0"
        key.failure(:missing)
      elsif !value.to_s.match?(/\A\d+\z/) || !(1..100).cover?(value.to_i)
        key.failure(:invalid_range)
      end
    end
  end

  rule(:vat_lower_rate_reg_no) do
    if values[:vat_rate] == 5
      if value.blank?
        key.failure(:missing)
      elsif !value.to_s.match?(/\A\d{9}\z/)
        key.failure(:invalid)
      end
    end
  end
end
