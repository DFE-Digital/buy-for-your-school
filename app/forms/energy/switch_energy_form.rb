# Switch Energy Form
#
class Energy::SwitchEnergyForm < Energy::Form
  option :switching_energy_type, Types::Params::Symbol, optional: true

  # @return [Array<String>] electricity, gas, gas_electricity
  def switching_energy_type_options
    @switching_energy_type_options = Energy::OnboardingCaseOrganisation.switching_energy_types.keys
  end
end
