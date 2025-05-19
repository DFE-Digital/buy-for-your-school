class Energy::BillingAddressConfirmationFormSchema < Schema
  config.messages.top_namespace = :billing_address_confirmation

  params do
    required(:billing_invoice_address_source_id).value(:string)
  end

  rule(:billing_invoice_address_source_id) do
    key.failure(:missing) if value.blank?
  end
end
