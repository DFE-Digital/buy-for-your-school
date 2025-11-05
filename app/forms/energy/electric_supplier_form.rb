# Switch Energy Form
#
class Energy::ElectricSupplierForm < Energy::Form
  option :electric_current_supplier, Types::Params::Symbol, optional: true
  option :electric_current_contract_end_date, Types::DateField, optional: true
  option :electric_current_supplier_other, Types::Params::Symbol, optional: true

  def current_supplier_options
    @current_supplier_options = Energy::OnboardingCaseOrganisation::CURRENT_SUPPLIERS.keys
  end
end
