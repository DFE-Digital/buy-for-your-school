class Energy::GasSingleMultiForm < Energy::Form
  option :gas_single_multi, Types::Params::Symbol, optional: true

  def single_multi_options
    Energy::OnboardingCaseOrganisation::GAS_SINGLE_MULTI.keys
  end
end
