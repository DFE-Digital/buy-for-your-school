# Gas Electricity Meter Type Form
#
class Energy::ElectricityMeterTypeForm < Energy::Form
  option :electricity_meter_type, Types::Params::Symbol, optional: true

  # @return [Array<String>] single, multi
  def electricity_meter_type_options
    @electricity_meter_type_options = Energy::OnboardingCaseOrganisation.electricity_meter_types.keys
  end
end
