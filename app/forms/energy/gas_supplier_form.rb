# Switch Energy Form
#
class Energy::GasSupplierForm < Energy::Form
  option :gas_current_supplier, Types::Params::Symbol, optional: true
  option :gas_current_contract_end_date, Types::DateField, optional: true
  option :gas_current_supplier_other, Types::Params::Symbol, optional: true

  def current_supplier_options
    @current_supplier_options = Energy::OnboardingCaseOrganisation::CURRENT_SUPPLIERS.keys
  end
end
