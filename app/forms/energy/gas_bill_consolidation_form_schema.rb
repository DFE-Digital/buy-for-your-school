# Validate Gas Bill Consolidation Form
#
class Energy::GasBillConsolidationFormSchema < Schema
  config.messages.top_namespace = :gas_bill_consolidation_form

  params do
    required(:gas_bill_consolidation).value(:string)
  end

  rule(:gas_bill_consolidation) do
    key.failure(:missing) if value.blank?
  end
end
