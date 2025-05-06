# Gas Bill Consolidation Form
#
class Energy::GasBillConsolidationForm < Energy::Form
  option :gas_bill_consolidation, Types::ConfirmationField, optional: true
end
