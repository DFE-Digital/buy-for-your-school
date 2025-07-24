class Energy::BillingPreferencesFormSchema < Schema
  config.messages.top_namespace = :billing_preferences

  params do
    required(:billing_payment_method).value(:string)
    required(:billing_payment_terms).value(:string)
    required(:billing_invoicing_method).value(:string)
    required(:billing_invoicing_email).value(:string)
  end

  rule(:billing_payment_method) do
    key.failure(:missing) if value.blank?
  end

  rule(:billing_payment_terms) do
    key.failure(:missing) if value.blank?
  end

  rule(:billing_invoicing_method) do
    key.failure(:missing) if value.blank?
  end

  rule(:billing_invoicing_email) do
    if values[:billing_invoicing_method] == "email"
      if value.blank?
        key.failure(:missing)
      elsif !URI::MailTo::EMAIL_REGEXP.match?(value)
        key.failure(:invalid)
      end
    end
  end
end
