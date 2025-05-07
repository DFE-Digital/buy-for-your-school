class Energy::ElectricityBillConsolidationFormSchema < Schema
  config.messages.top_namespace = :electricity_bill_consolidation_form

  params do
    required(:electricity_bill_consolidation).value(:string)
  end

  rule(:electricity_bill_consolidation) do
    key.failure(:missing) if value.blank?
  end
end
