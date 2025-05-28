class Energy::BillingAddressConfirmationForm < Energy::Form
  option :billing_invoice_address_source_id, Types::Params::String, optional: true
end
