class Energy::BillingPreferencesForm < Energy::Form
  option :billing_payment_method, Types::Params::Symbol, optional: true
  option :billing_payment_terms, Types::Params::Symbol, optional: true
  option :billing_invoicing_method, Types::Params::Symbol, optional: true
  option :billing_invoicing_email, Types::Params::Symbol, optional: true

  def payment_method_options
    Energy::OnboardingCaseOrganisation::BILLING_PAYMENT_METHOD.keys
  end

  def payment_terms_options
    Energy::OnboardingCaseOrganisation::BILLING_PAYMENT_TERMS.keys
  end

  def invoicing_method_options
    Energy::OnboardingCaseOrganisation::BILLING_INVOICING_METHOD.keys
  end
end
